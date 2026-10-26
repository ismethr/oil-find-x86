import Foundation

/// The x86 fork uses its own bundle identifier. Carry settings over once from builds
/// that still used the upstream identifier, so upgrading keeps hotkey, scopes and language.
enum ForkDefaultsMigration {
    static let legacyDomain = "com.oiloil.find"

    static func run(defaults: UserDefaults = .standard, from legacy: String = legacyDomain, to domain: String? = Bundle.main.bundleIdentifier) {
        guard let domain, domain != legacy,
              defaults.persistentDomain(forName: domain)?.isEmpty ?? true,
              let values = defaults.persistentDomain(forName: legacy), !values.isEmpty else { return }
        defaults.setPersistentDomain(values, forName: domain)
    }
}
