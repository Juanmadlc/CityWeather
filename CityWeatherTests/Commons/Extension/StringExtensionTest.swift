import Foundation
import Testing
@testable import CityWeather

struct StringExtensionTest {
    @Test
    func `Localization returns key when translation does not exist`() {
        let key = "missing.localization.key.\(UUID().uuidString)"

        #expect(key.localized() == key)
    }
}
