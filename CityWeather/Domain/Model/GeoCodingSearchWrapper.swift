//
//  GeoCodingSearch.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 02/09/2026.
//

import Foundation

struct GeoCodingSearchWrapper: Decodable {
    let results: [CitySearchResult]?
    let generationtimeMs: Double?

    enum CodingKeys: String, CodingKey {
        case results
        case generationtimeMs = "generationtime_ms"
    }
}

// MARK: - CitySearchResult
struct CitySearchResult: Decodable {
    let id: Int?
    let name: String?
    let latitude, longitude: Double?
    let elevation: Double?
    let featureCode: String?
    let countryCode: String?
    let admin1Id, admin2Id, admin3Id: Int?
    let timezone: String?
    let population: Int?
    let postcodes: [String]?
    let countryId: Int?
    let country: String?
    let admin1, admin2, admin3: String?

    enum CodingKeys: String, CodingKey {
        case id, name, latitude, longitude, elevation
        case featureCode = "feature_code"
        case countryCode = "country_code"
        case admin1Id = "admin1_id"
        case admin2Id = "admin2_id"
        case admin3Id = "admin3_id"
        case timezone, population, postcodes
        case countryId = "country_id"
        case country, admin1, admin2, admin3
    }
}
