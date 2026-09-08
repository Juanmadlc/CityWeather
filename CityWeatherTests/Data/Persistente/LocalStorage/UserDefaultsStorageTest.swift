//
//  UserDefaultsStorageTest.swift
//  CityWeatherTests
//
//  Created by Juan Manuel de la Cruz on 08/09/2026.
//

import XCTest
@testable import CityWeather

final class UserDefaultsStorageTests: XCTestCase {

    // MARK: - Properties

    private var sut: UserDefaultsStorage!

    // MARK: - Life Cycle

    override func setUp() {
        super.setUp()

        sut = UserDefaultsStorage()

        UserDefaults.standard.removeObject(forKey: "selectedCity")
        UserDefaults.standard.removeObject(forKey: "selectedCountry")
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "selectedCity")
        UserDefaults.standard.removeObject(forKey: "selectedCountry")

        sut = nil
        super.tearDown()
    }

    // MARK: - Tests

    func testSutIsNotNil() {
        XCTAssertNotNil(sut)
    }

    func testSaveSelectedCity_ShouldSaveCityInUserDefaults() {

        // Given
        let expectedCity = "Madrid"

        // When
        sut.saveSelectedCity(expectedCity)

        // Then
        XCTAssertEqual(sut.getSelectedCity(), expectedCity)
    }

    func testSaveSelectedCountry_ShouldSaveCountryInUserDefaults() {

        // Given
        let expectedCountry = "ES"

        // When
        sut.saveSelectedCountry(expectedCountry)

        // Then
        XCTAssertEqual(sut.getSelectedCountry(), expectedCountry)
    }

    func testGetSelectedCity_WhenNothingSaved_ShouldReturnNil() {

        // When
        let city = sut.getSelectedCity()

        // Then
        XCTAssertNil(city)
    }

    func testGetSelectedCountry_WhenNothingSaved_ShouldReturnNil() {

        // When
        let country = sut.getSelectedCountry()

        // Then
        XCTAssertNil(country)
    }

    func testSaveCity_DoesNotModifyCountry() {

        // Given
        sut.saveSelectedCountry("ES")

        // When
        sut.saveSelectedCity("Madrid")

        // Then
        XCTAssertEqual(sut.getSelectedCountry(), "ES")
    }

    func testSaveCountry_DoesNotModifyCity() {

        // Given
        sut.saveSelectedCity("Madrid")

        // When
        sut.saveSelectedCountry("ES")

        // Then
        XCTAssertEqual(sut.getSelectedCity(), "Madrid")
    }
}
