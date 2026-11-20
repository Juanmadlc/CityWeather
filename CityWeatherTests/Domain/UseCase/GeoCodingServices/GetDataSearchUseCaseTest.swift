//
//  GetDataSearchUseCaseTest.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 20/11/2026.
//

import Foundation
import Testing
@testable import CityWeather

@Suite
struct GetDataSearchUseCaseTest {

    @Test
    func `Execute passes the searched name to the repository`() async throws {
        let repository = MockGeoCodingRepository(result: .success(try geoSearchFixture()))
        let sut = GetDataSearchUseCase(modelProtocol: repository, name: "Barcelona")

        _ = try await sut.execute()

        #expect(repository.requestedNames == ["Barcelona"])
    }

    @Test
    func `Execute returns the search result provided by the repository`() async throws {
        let fixture = try geoSearchFixture()
        let repository = MockGeoCodingRepository(result: .success(fixture))
        let sut = GetDataSearchUseCase(modelProtocol: repository, name: "Barcelona")

        let result = try await sut.execute()

        #expect(result.results?.count == fixture.results?.count)
        #expect(result.results?.first?.name == fixture.results?.first?.name)
        #expect(result.results?.first?.countryCode == fixture.results?.first?.countryCode)
    }

    @Test
    func `Execute propagates the repository error`() async {
        let repository = MockGeoCodingRepository(result: .failure(GeoCodingServicesModelProtocolError.unaccessible))
        let sut = GetDataSearchUseCase(modelProtocol: repository, name: "Barcelona")

        await #expect(throws: GeoCodingServicesModelProtocolError.self) {
            try await sut.execute()
        }
        #expect(repository.requestedNames == ["Barcelona"])
    }
}

private final class MockGeoCodingRepository: GeoCodingServicesModelProtocol, @unchecked Sendable {
    private let result: Result<GeoCodingSearchWrapper, Error>
    private(set) var requestedNames: [String] = []

    init(result: Result<GeoCodingSearchWrapper, Error>) {
        self.result = result
    }

    func getDataSearch(name: String) async throws -> GeoCodingSearchWrapper {
        requestedNames.append(name)
        return try result.get()
    }
}

private func geoSearchFixture() throws -> GeoCodingSearchWrapper {
    try JSONDecoder().decode(GeoCodingSearchWrapper.self, from: MocksManager.shared.getMockGeoDataSearch())
}
