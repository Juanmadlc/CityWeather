//
//  GeoCodingServicesAPIClientTest.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 09/11/2026.
//

import Foundation
import Testing
@testable import CityWeather

struct GeoCodingServicesAPIClientTest {
    @Test
    func `Search request decodes a valid response`() async throws {
        let network = StubGeoCodingServicesNetwork(
            response: .data(
                Data(
                    """
                    {
                        "results": [{
                            "id": 3128760,
                            "name": "Barcelona",
                            "latitude": 41.38879,
                            "longitude": 2.15899,
                            "country_code": "ES",
                            "country": "España"
                        }],
                        "generationtime_ms": 0.15
                    }
                    """.utf8
                )
            )
        )
        let sut = GeoCodingServicesAPIClient(network: network)

        let response = try await sut.getDataSearch(name: "Barcelona")
        let firstResult = try #require(response.results?.first)

        #expect(firstResult.id == 3_128_760)
        #expect(firstResult.name == "Barcelona")
        #expect(firstResult.latitude == 41.38879)
        #expect(firstResult.longitude == 2.15899)
        #expect(firstResult.countryCode == "ES")
        #expect(response.generationtimeMs == 0.15)
    }

    @Test
    func `Search request propagates the network error`() async {
        let sut = GeoCodingServicesAPIClient(
            network: StubGeoCodingServicesNetwork(response: .failure)
        )

        do {
            _ = try await sut.getDataSearch(name: "Barcelona")
            Issue.record("Expected the network error to be propagated")
        } catch TestError.expected {
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }

    @Test
    func `Search request throws when the response is not valid JSON`() async {
        let sut = GeoCodingServicesAPIClient(
            network: StubGeoCodingServicesNetwork(response: .data(Data("invalid JSON".utf8)))
        )

        do {
            _ = try await sut.getDataSearch(name: "Barcelona")
            Issue.record("Expected decoding to fail for invalid JSON")
        } catch is DecodingError {
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }
}

private struct StubGeoCodingServicesNetwork: GeoCodingServicesNetworkProtocol {
    enum Response: Sendable {
        case data(Data)
        case failure
    }

    let response: Response

    func getDataSearch(name: String) async throws -> Data {
        switch response {
        case let .data(data):
            return data
        case .failure:
            throw TestError.expected
        }
    }
}

private enum TestError: Error {
    case expected
}
