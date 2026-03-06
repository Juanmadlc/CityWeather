//
//  NetworkManager.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 6/3/26.
//

import Foundation

class NetworkManager: NetworkDispatcher {
    var baseURL: String
    let session: URLSession

    public init(baseURL: String) {
        self.baseURL = baseURL
        self.session = URLSession(configuration: Self.urlSessionConfiguration)
    }

    static var urlSessionConfiguration: URLSessionConfiguration {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 30
        configuration.waitsForConnectivity = false
        configuration.httpMaximumConnectionsPerHost = 10
        return configuration
    }
}

