import Foundation
import Darwin

public final class IndexManager {
    public enum State { case idle, loading, scanning, ready }
    // The requested config belongs to eventQueue; each scan captures its own value.
    private var config: IndexConfig
    private let dbURL: URL
    private let lock = NSLock()
    private let eventQueue = DispatchQueue(label: "com.oiloil.find.events", qos: .utility)
    private let scanQueue = DispatchQueue(label: "com.oiloil.find.scan", qos: .utility)
    private let saveQueue = DispatchQueue(label: "com.oiloil.find.save", qos: .background)
    private let eventKey = DispatchSpecificKey<Bool>(), saveKey = DispatchSpecificKey<Bool>()
    private var currentState: State = .idle, currentStore: IndexStore?, currentScanner: Scanner?
    private var rescanning = false, active = false, generation = 0, summary: ApplySummary?
    private var watcher: FSWatcher?, timer: DispatchSourceTimer?
    internal var onBeforeLoadedHashBuild: (() -> Void)?
    internal var onRescanStart: (() -> Void)?
    private var recoveryRescanPending = false
    private var updater: IndexUpdater?
    private weak var savedStore: IndexStore?
    private var savedVersion: UInt64 = 0
    private var pendingNotification: DispatchWorkItem?, lastNotification = -Double.infinity
    private var stateCallback: ((State) -> Void)?, indexCallback: (() -> Void)?, batchCallback: ((ApplySummary) -> Void)?
    private var replayCount = 0, dataPrefix = false, hashMs = 0.0
    public init(config: IndexConfig, dbURL: URL) {
        self.config = config; self.dbURL = dbURL
        eventQueue.setSpecific(key: eventKey, value: true); saveQueue.setSpecific(key: saveKey, value: true)
    }
    deinit { timer?.cancel(); pendingNotification?.cancel(); currentScanner?.cancel() }
    private func locked<T>(_ body: () -> T) -> T { lock.lock(); defer { lock.unlock() }; return body() }
    public var state: State { locked { currentState } }
    public var store: IndexStore? { locked { currentStore } }
    public var scannedCount: Int { let scanner = locked { currentScanner }; return scanner?.scannedCount ?? 0 }
    public var isRescanning: Bool { locked { rescanning } }
    public var lastSummary: ApplySummary? { locked { summary } }
    public var replayedEventCount: Int { locked { replayCount } }
    public var reportedDataPrefix: Bool { locked { dataPrefix } }
    public var buildHashMs: Double { locked { hashMs } }
    public var onStateChange: ((State) -> Void)? { get { locked { stateCallback } } set { locked { stateCallback = newValue } } }
    public var onIndexChange: (() -> Void)? { get { locked { indexCallback } } set { locked { indexCallback = newValue } } }
    // Each batch is observable independently of the UI notification throttle.
    public var onApply: ((ApplySummary) -> Void)? { get { locked { batchCallback } } set { locked { batchCallback = newValue } } }
    private func setState(_ state: State) {
        let callback = locked { () -> ((State) -> Void)? in
            if currentState == state { return nil }; currentState = state; return stateCallback
        }
        DispatchQueue.main.async { callback?(state) }
    }
    private func valid(_ token: Int) -> Bool { locked { active && generation == token } }
    private func deviceUUID(config: IndexConfig) -> String? {
        var s = stat(); guard stat(config.rootPath == "/" ? "/System/Volumes/Data" : config.rootPath, &s) == 0 else { return nil }
        return FSWatcher.uuid(forDevice: s.st_dev)
    }
    public func start() {
        eventQueue.async { [weak self] in
            guard let self, !self.locked({ self.active }) else { return }
            let token = self.locked { self.active = true; self.replayCount = 0; self.dataPrefix = false; self.generation += 1; return self.generation }
            self.setState(.loading)
            let config = self.config
            self.scanQueue.async { [weak self] in
                guard let self, self.valid(token) else { return }
                let uuid = self.deviceUUID(config: config)
                if let s = IndexStore.load(from: self.dbURL.path), s.configFingerprint == config.fingerprint,
                   s.rootPath == config.rootPath, let uuid, s.fsEventsUUID == uuid {
                    self.eventQueue.async {
                        guard self.valid(token) else { return }
                        self.locked { self.currentStore = s; self.hashMs = 0 }
                        self.saveQueue.sync { self.savedStore = s; self.savedVersion = s.version }
                        self.setState(.ready); self.notifyIndex(replaced: true)
                        DispatchQueue.global(qos: .utility).async { _ = Pinyin.shared }
                        self.onBeforeLoadedHashBuild?()
                        let begin = CFAbsoluteTimeGetCurrent()
                        let built = s.makeHash()
                        s.write { s.installHash(built) }
                        self.locked { self.hashMs = (CFAbsoluteTimeGetCurrent() - begin) * 1000 }
                        self.updater = IndexUpdater(config: config)
                        self.startWatcher(s, token: token); self.startTimer()
                        self.scanLatestConfigIfNeeded()
                        if UInt64(Date().timeIntervalSince1970) > s.scanFinishedAt + 7*86400 {
                            self.eventQueue.asyncAfter(deadline: .now()+60) { [weak self] in if let self, self.valid(token) { self.rescan() } }
                        }
                    }
                } else {
                    guard self.valid(token) else { return }
                    try? FileManager.default.removeItem(at: self.dbURL)
                    self.eventQueue.async { if self.valid(token) { self.setState(.scanning) } }
                    self.scan(config: config, token: token, isRescan: false, uuid: uuid)
                }
            }
        }
    }
    private func scan(config: IndexConfig, token: Int, isRescan: Bool, uuid: String?) {
        let startId = FSWatcher.currentEventId(), scanner = Scanner(config: config)
        let proceed = locked { () -> Bool in
            guard active && generation == token else { return false }; currentScanner = scanner; return true
        }
        guard proceed else { return }
        guard let output = scanner.run(), valid(token) else {
            eventQueue.async { if self.valid(token) { self.locked { self.currentScanner = nil; self.rescanning = false; if !isRescan { self.active = false } }; if !isRescan { self.setState(.idle) } } }; return
        }
        let s = IndexStore(scan: output, config: config)
        let begin = CFAbsoluteTimeGetCurrent(); s.write { s.buildHash() }
        let ms = (CFAbsoluteTimeGetCurrent()-begin)*1000
        s.lastEventId = startId; s.scanFinishedAt = UInt64(Date().timeIntervalSince1970); s.fsEventsUUID = uuid ?? ""
        eventQueue.async { [weak self] in
            guard let self, self.valid(token) else { return }
            self.watcher?.stop(); self.watcher = nil
            self.locked { self.currentStore = s; self.currentScanner = nil; self.rescanning = false; self.hashMs = ms }
            self.updater = IndexUpdater(config: config)
            self.setState(.ready); self.notifyIndex(replaced: true)
            DispatchQueue.global(qos: .utility).async { _ = Pinyin.shared }
            self.saveNow(); self.startWatcher(s, token: token); self.startTimer()
            self.scanLatestConfigIfNeeded()
            self.startPendingRecovery()
        }
    }
    private func startWatcher(_ s: IndexStore, token: Int) {
        let w = FSWatcher(paths: [s.rootPath], sinceWhen: s.lastEventId, queue: eventQueue) { [weak self] changes, rescan in
            guard let self, self.valid(token) else { return }
            if let w = self.watcher { self.locked { self.replayCount = w.replayedEventCount; self.dataPrefix = w.reportedDataPrefix } }
            self.handleEvents(changes, mustRescanAll: rescan)
        }
        watcher = w
        if !w.start() { fputs("Oil Find: cannot start FSEvents\n", stderr) }
    }
    // Test injection and FSEvents share the event-queue implementation.
    internal func injectEvents(_ changes: [FSChange], mustRescanAll: Bool) {
        eventQueue.async { [weak self] in
            guard let self, self.locked({ self.active }) else { return }
            self.handleEvents(changes, mustRescanAll: mustRescanAll)
        }
    }
    private func handleEvents(_ changes: [FSChange], mustRescanAll: Bool) {
        if mustRescanAll {
            if isRescanning { recoveryRescanPending = true }
            else { beginRescan() }
            return
        }
        guard !changes.isEmpty, let store = self.store, let updater else { return }
        let result = updater.apply(changes, to: store)
        let callback = locked { self.summary = result; return batchCallback }
        DispatchQueue.main.async { callback?(result) }
        if store.read({ store.needsCompaction }) {
            // The event queue is the sole writer; readers may continue during copying.
            let compact = store.read { store.compacted() }
            locked { currentStore = compact }; notifyIndex(replaced: true)
        } else { notifyIndex(replaced: false) }
    }
    public func explain(path: String) -> CoverageExplanation {
        let config = DispatchQueue.getSpecific(key: eventKey) == true ? self.config : eventQueue.sync { self.config }
        return Coverage.explain(path: path, config: config, store: store)
    }
    public func rescan() {
        eventQueue.async { [weak self] in
            self?.beginRescan()
        }
    }
    public func updateConfig(_ config: IndexConfig) {
        eventQueue.async { [weak self] in
            guard let self, self.config.fingerprint != config.fingerprint else { return }
            self.config = config
            self.beginRescan()
        }
    }
    private func scanLatestConfigIfNeeded() {
        if store?.configFingerprint != config.fingerprint { beginRescan() }
    }
    private func beginRescan() {
        let token: Int? = locked {
            guard active && currentState == .ready && !rescanning else { return nil }
            rescanning = true; return generation
        }
        guard let token else { return }
        let config = self.config
        onRescanStart?()
        scanQueue.async { [weak self] in
            if let self, self.valid(token) {
                self.scan(config: config, token: token, isRescan: true, uuid: self.deviceUUID(config: config))
            }
        }
    }
    private func startPendingRecovery() {
        guard recoveryRescanPending, !isRescanning else { return }
        recoveryRescanPending = false
        beginRescan()
    }
    private func notifyIndex(replaced: Bool) {
        let now = CFAbsoluteTimeGetCurrent()
        if replaced || now-lastNotification >= 1 {
            pendingNotification?.cancel(); pendingNotification = nil; lastNotification = now
            let callback = locked { indexCallback }; DispatchQueue.main.async { callback?() }
        } else if pendingNotification == nil {
            let work = DispatchWorkItem { [weak self] in
                guard let self, self.locked({ self.active }) else { return }
                self.pendingNotification = nil; self.notifyIndex(replaced: false)
            }
            pendingNotification = work; eventQueue.asyncAfter(deadline: .now() + (1-(now-lastNotification)), execute: work)
        }
    }
    private func startTimer() {
        if timer != nil { return }
        let timer = DispatchSource.makeTimerSource(queue: eventQueue)
        timer.schedule(deadline: .now()+1800, repeating: 1800)
        timer.setEventHandler { [weak self] in self?.saveQueue.async { [weak self] in self?.saveChanged() } }
        self.timer = timer; timer.resume()
    }
    private func saveChanged() {
        guard let s = store else { return }
        let version = s.read { s.version }
        if savedStore === s && savedVersion == version { return }
        do {
            // The saved version is captured under the same read lock as the file snapshot.
            let saved = try s.saveSnapshot(to: dbURL.path)
            savedStore = s; savedVersion = saved
        } catch { fputs("Oil Find: save failed: \(error)\n", stderr) }
    }
    public func saveNow() {
        if DispatchQueue.getSpecific(key: saveKey) == true { saveChanged() }
        else { saveQueue.sync { saveChanged() } }
    }
    public func stop() {
        let stopEvents = {
            self.locked { self.active = false; self.generation += 1; self.currentScanner?.cancel(); self.currentScanner = nil; self.rescanning = false }
            self.recoveryRescanPending = false
            self.watcher?.stop(); self.watcher = nil
            self.timer?.cancel(); self.timer = nil; self.pendingNotification?.cancel(); self.pendingNotification = nil
            self.setState(.idle)
        }
        if DispatchQueue.getSpecific(key: eventKey) == true { stopEvents() } else { eventQueue.sync(execute: stopEvents) }
        // Drain loading/scanning before saving so a stale job cannot replace or unlink the database.
        scanQueue.sync {}; saveNow()
    }
}
