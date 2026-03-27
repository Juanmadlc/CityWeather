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
    
    func getMockDataWeather() throws -> MapWrapper {
        let jsonString = """
        {
            "coord": {
                "lon": -2.3333,
                "lat": 37.1667
            },
            "weather": [
                {
                    "id": 802,
                    "main": "Clouds",
                    "description": "nubes dispersas",
                    "icon": "03d"
                }
            ],
            "base": "stations",
            "main": {
                "temp": 11.66,
                "feels_like": 10.29,
                "temp_min": 11.66,
                "temp_max": 11.66,
                "pressure": 1013,
                "humidity": 54,
                "sea_level": 1013,
                "grnd_level": 924
            },
            "visibility": 10000,
            "wind": {
                "speed": 3.81,
                "deg": 87,
                "gust": 3.61
            },
            "clouds": {
                "all": 28
            },
            "dt": 1774627559,
            "sys": {
                "country": "ES",
                "sunrise": 1774591361,
                "sunset": 1774635997
            },
            "timezone": 3600,
            "id": 2521883,
            "name": "Almeria",
            "cod": 200
        }
        """
        guard let data = jsonString.data(using: .utf8) else {
            throw NSError(domain: "mockDataWeather", code: 500, userInfo: [NSLocalizedDescriptionKey: "No se pudo codificar el JSON de mock a Data"])
        }
        let decoder = JSONDecoder()
        do {
            let model = try decoder.decode(MapWrapper.self, from: data)
            return model
        } catch {
            throw NSError(domain: "mockDataWeather", code: 501, userInfo: [NSLocalizedDescriptionKey: "No se pudo decodificar el JSON de mock a MapWrapper: \(error)"])
        }
    }
}
