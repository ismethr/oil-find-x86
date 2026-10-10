import XCTest
@testable import OilFind

final class ForkDefaultsMigrationTests: XCTestCase {
    private func domains() -> (UserDefaults, String, String) {
        let id = UUID().uuidString, legacy = "OilFindMigrationLegacy-\(id)", current = "OilFindMigrationCurrent-\(id)"
        let defaults = UserDefaults.standard
        addTeardownBlock { defaults.removePersistentDomain(forName: legacy); defaults.removePersistentDomain(forName: current) }
        return (defaults, legacy, current)
    }

    func testCopiesLegacySettingsOnce() {
        let (defaults, legacy, current) = domains()
        defaults.setPersistentDomain(["hotKeyCode": 3, "didFinishOnboarding": true], forName: legacy)
        ForkDefaultsMigration.run(defaults: defaults, from: legacy, to: current)
        XCTAssertEqual(defaults.persistentDomain(forName: current)?["hotKeyCode"] as? Int, 3)
        XCTAssertEqual(defaults.persistentDomain(forName: current)?["didFinishOnboarding"] as? Bool, true)
    }

    func testKeepsExistingSettings() {
        let (defaults, legacy, current) = domains()
        defaults.setPersistentDomain(["hotKeyCode": 3], forName: legacy)
        defaults.setPersistentDomain(["hotKeyCode": 5], forName: current)
        ForkDefaultsMigration.run(defaults: defaults, from: legacy, to: current)
        XCTAssertEqual(defaults.persistentDomain(forName: current)?["hotKeyCode"] as? Int, 5)
    }

    func testDoesNothingWithoutLegacySettings() {
        let (defaults, legacy, current) = domains()
        ForkDefaultsMigration.run(defaults: defaults, from: legacy, to: current)
        XCTAssertNil(defaults.persistentDomain(forName: current))
    }
}
