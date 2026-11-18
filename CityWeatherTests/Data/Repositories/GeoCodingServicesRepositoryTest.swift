//
//  GeoCodingServicesRepositoryTest.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 18/11/2026.
//

import Foundation
import Testing
@testable import CityWeather

@Suite
struct GeoCodingServicesRepositoryTest {

    @Test
    func `Repeated search within time to live returns cached result without calling the network`() async throws {
        let apiClient = CountingGeoCodingAPIClient(result: .success(try searchWrapper(names: ["Madrid"])))
        let sut = makeSUT(apiClient: apiClient, clock: TestClock())

        let first = try await sut.getDataSearch(name: "Madrid")
        let second = try await sut.getDataSearch(name: "Madrid")

        #expect(apiClient.callCount(for: "Madrid") == 1)
        #expect(first.results?.first?.name == "Madrid")
        #expect(second.results?.first?.name == "Madrid")
    }

    @Test
    func `Expired entry is fetched again from the network and the cache is updated`() async throws {
        let clock = TestClock()
        let apiClient = CountingGeoCodingAPIClient(result: .success(try searchWrapper(names: ["Madrid"])))
        let sut = makeSUT(apiClient: apiClient, clock: clock)
        _ = try await sut.getDataSearch(name: "Madrid")

        clock.advance(by: timeToLive + 1)
        apiClient.result = .success(try searchWrapper(names: ["Madrid updated"]))
        let refreshed = try await sut.getDataSearch(name: "Madrid")
        let cachedAgain = try await sut.getDataSearch(name: "Madrid")

        #expect(apiClient.callCount(for: "Madrid") == 2)
        #expect(refreshed.results?.first?.name == "Madrid updated")
        #expect(cachedAgain.results?.first?.name == "Madrid updated")
    }

    @Test
    func `Entry just before expiring is still served from the cache`() async throws {
        let clock = TestClock()
        let apiClient = CountingGeoCodingAPIClient(result: .success(try searchWrapper(names: ["Madrid"])))
        let sut = makeSUT(apiClient: apiClient, clock: clock)
        _ = try await sut.getDataSearch(name: "Madrid")

        clock.advance(by: timeToLive - 1)
        _ = try await sut.getDataSearch(name: "Madrid")

        #expect(apiClient.callCount(for: "Madrid") == 1)
    }

    @Test
    func `Different queries are cached independently`() async throws {
        let apiClient = CountingGeoCodingAPIClient(result: .success(try searchWrapper(names: ["City"])))
        let sut = makeSUT(apiClient: apiClient, clock: TestClock())

        _ = try await sut.getDataSearch(name: "Madrid")
        _ = try await sut.getDataSearch(name: "Barcelona")
        _ = try await sut.getDataSearch(name: "Madrid")
        _ = try await sut.getDataSearch(name: "Barcelona")

        #expect(apiClient.callCount(for: "Madrid") == 1)
        #expect(apiClient.callCount(for: "Barcelona") == 1)
    }

    @Test
    func `Cache key ignores letter case and surrounding whitespace`() async throws {
        let apiClient = CountingGeoCodingAPIClient(result: .success(try searchWrapper(names: ["Madrid"])))
        let sut = makeSUT(apiClient: apiClient, clock: TestClock())

        _ = try await sut.getDataSearch(name: "Madrid")
        _ = try await sut.getDataSearch(name: "  madrid ")

        #expect(apiClient.totalCallCount == 1)
    }

    @Test
    func `Failed requests are not cached`() async throws {
        let apiClient = CountingGeoCodingAPIClient(result: .failure(GeoCodingServicesModelProtocolError.unaccessible))
        let sut = makeSUT(apiClient: apiClient, clock: TestClock())

        await #expect(throws: GeoCodingServicesModelProtocolError.self) {
            try await sut.getDataSearch(name: "Madrid")
        }

        apiClient.result = .success(try searchWrapper(names: ["Madrid"]))
        let result = try await sut.getDataSearch(name: "Madrid")

        #expect(apiClient.callCount(for: "Madrid") == 2)
        #expect(result.results?.first?.name == "Madrid")
    }
}

private let timeToLive: TimeInterval = 300

private func makeSUT(apiClient: CountingGeoCodingAPIClient, clock: TestClock) -> GeoCodingServicesRepository {
    let cache = GeoCodingSearchCache(timeToLive: timeToLive, now: { clock.current })
    return GeoCodingServicesRepository(apiClient: apiClient, cache: cache)
}

private final class TestClock: @unchecked Sendable {
    private(set) var current = Date(timeIntervalSince1970: 0)

    func advance(by interval: TimeInterval) {
        current = current.addingTimeInterval(interval)
    }
}

private final class CountingGeoCodingAPIClient: GeoCodingServicesAPIClientProtocol, @unchecked Sendable {
    var result: Result<GeoCodingSearchWrapper, Error>
    private var requestedNames: [String] = []

    init(result: Result<GeoCodingSearchWrapper, Error>) {
        self.result = result
    }

    var totalCallCount: Int {
        requestedNames.count
    }

    func callCount(for name: String) -> Int {
        requestedNames.filter { $0 == name }.count
    }

    func getDataSearch(name: String) async throws -> GeoCodingSearchWrapper {
        requestedNames.append(name)
        return try result.get()
    }
}

private func searchWrapper(names: [String]) throws -> GeoCodingSearchWrapper {
    let json: [String: Any] = ["results": names.map { ["name": $0] }]
    let data = try JSONSerialization.data(withJSONObject: json)
    return try JSONDecoder().decode(GeoCodingSearchWrapper.self, from: data)
}
