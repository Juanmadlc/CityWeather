//
//  GetDataSearchGeoUseCase.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 02/09/2026.
//

import Foundation

final class GetDataSearchUseCase: AsyncUseCase {
    // MARK: - Properties
    let modelProtocol: GeoCodingServicesModelProtocol
    private let name: String

    // MARK: - Init
    init(modelProtocol: GeoCodingServicesModelProtocol, name: String) {
        self.modelProtocol = modelProtocol
        self.name = name
    }

    // MARK: - Execute
    func execute() async throws -> GeoCodingSearchWrapper {
        try await modelProtocol.getDataSearch(name: name)
    }
}
