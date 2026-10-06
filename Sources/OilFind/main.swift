import AppKit
import OilFindCore

let arguments = Array(CommandLine.arguments.dropFirst())
#if DEBUG
if arguments.contains("--snapshot") {
    do { try Snapshot.run(arguments); exit(0) }
    catch { fputs("Oil Find snapshot: \(error)\n", stderr); exit(1) }
}
if UpdateExercise.handles(arguments) {
    do { try UpdateExercise.start(arguments); NSApplication.shared.run(); exit(0) }
    catch { fputs("Oil Find update exercise: \(error)\n", stderr); exit(1) }
}
#endif
SystemUpdateFiles().registerLaunch(application: Bundle.main.bundleURL, current: UpdateManager.current)
let app = NSApplication.shared
SettingsPreferences.register()
let delegate = AppDelegate()
app.delegate = delegate
app.run()
