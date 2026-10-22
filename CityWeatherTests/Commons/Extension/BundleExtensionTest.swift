import Foundation
import Testing
@testable import CityWeather

@Suite(.serialized)
final class BundleExtensionTest {
    private let preferencesURL: URL
    private let originalPreferencesData: Data?

    init() throws {
        let documentsDirectory = try #require(
            FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        )
        preferencesURL = documentsDirectory.appendingPathComponent("Preferences.plist")

        if FileManager.default.fileExists(atPath: preferencesURL.path) {
            originalPreferencesData = try Data(contentsOf: preferencesURL)
            try FileManager.default.removeItem(at: preferencesURL)
        } else {
            originalPreferencesData = nil
        }
    }

    deinit {
        try? FileManager.default.removeItem(at: preferencesURL)

        if let originalPreferencesData {
            try? originalPreferencesData.write(to: preferencesURL)
        }
    }

    @Test
    func `API environment persists production environment`() {
        Bundle.main.apiEnvironment = .pro

        #expect(Bundle.main.apiEnvironment == .pro)
    }

    @Test
    func `API environment persists development environment`() {
        Bundle.main.apiEnvironment = .dev

        #expect(Bundle.main.apiEnvironment == .dev)
    }
}
