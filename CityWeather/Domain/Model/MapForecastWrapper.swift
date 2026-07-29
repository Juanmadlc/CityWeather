//
//  MapForecastWrapper.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 27/7/26.
//

import Foundation

struct MapForecastWrapper: Decodable {
    let cod: String
    let message, cnt: Int
    let list: [ForecastItem]
    let city: City
}

struct ForecastItem: Decodable {
    let dt: Int
    let main: MainForecast
    let weather: [Weather]
    let clouds: Clouds
    let wind: Wind
    let visibility: Int
    let pop: Double
    let sys: SysForecast
    let dtTxt: String

    enum CodingKeys: String, CodingKey {
        case dt, main, weather, clouds, wind, visibility, pop, sys
        case dtTxt = "dt_txt"
    }
}

struct MainForecast: Decodable {
    let temp, feelsLike, tempMin, tempMax: Double
    let pressure, seaLevel, grndLevel, humidity: Int
    let tempKf: Double
    let dewPoint: Double

    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case pressure
        case seaLevel = "sea_level"
        case grndLevel = "grnd_level"
        case humidity
        case tempKf = "temp_kf"
        case dewPoint = "dew_point"
    }
}

struct SysForecast: Decodable {
    let pod: String
}

struct City: Decodable {
    let id: Int
    let name: String
    let coord: Coord
    let country: String
    let population, timezone, sunrise, sunset: Int
}
