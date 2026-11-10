//
//  MockGeoCodingServicesAPIClientTest.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 10/11/2026.
//

import Testing
@testable import CityWeather

struct MockGeoCodingServicesAPIClientTest {
    private let sut = MockGeoCodingServicesAPIClient()

    @Test
    func `Search request decodes the geocoding mock fixture`() async throws {
        let response = try await sut.getDataSearch(name: "Barcelona")
        let firstResult = try #require(response.results?.first)

        #expect(firstResult.id == 3_128_760)
        #expect(firstResult.name == "Barcelona")
        #expect(firstResult.latitude == 41.38879)
        #expect(firstResult.longitude == 2.15899)
        #expect(firstResult.countryCode == "ES")
        #expect(firstResult.country == "España")
    }
}
