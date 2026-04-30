//
//  MocksManager.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 27/3/26.
//

import Foundation

final class MocksManager {
    let isMockMode = false
    static let shared = MocksManager()
        
    func shouldUseMockData() -> Bool { // TODO: 01 Falta comprobar
        return isMockMode
    }
    // MARK: MOCKS
    func getMockDataWeather() throws -> Data {
        guard let path = Bundle.main.path(forResource: "mockWeather", ofType: "json") else {
            throw NSError(domain: "MapServicesClient", code: 404, userInfo: [NSLocalizedDescriptionKey: "Archivo JSON no encontrado"])
        }
        let url = URL(fileURLWithPath: path)
        let data = try Data(contentsOf: url)
        return data
    }
}
