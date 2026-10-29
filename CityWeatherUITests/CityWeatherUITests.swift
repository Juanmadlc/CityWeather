//
//  CityWeatherUITests.swift
//  CityWeatherUITests
//
//  Created by Juan Manuel de la Cruz on 27/3/25.
//

import XCTest

final class CityWeatherUITests: XCTestCase {

    override func setUpWithError() throws {
        // UI tests should stop immediately when a failure occurs.
        continueAfterFailure = false
    }

    @MainActor
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    @MainActor
    func testLaunchPerformance() {
        let app = XCUIApplication()

        // A launch metric is meaningful only when the app is not already running.
        app.terminate()

        measure(metrics: [XCTApplicationLaunchMetric()]) {
            app.launch()
        }
    }
}
