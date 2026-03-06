//
//  NetworkDispatcher.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 6/3/26.
//

import Foundation

enum NetworkDispatcherError: Error {
    case networkError(code: Int, errMessage: String = "Error_Network".localized())
}

protocol NetworkDispatcher {
    var session: URLSession { get }
    var baseURL: String { get }
}

extension NetworkDispatcher {
    
    func call(endpoint: NetworkCall) async throws -> Data {
        do {
            let request = try endpoint.urlRequest(baseURL: baseURL)
            let (data, response) = try await session.data(for: request)
            let httpResponse = response as? HTTPURLResponse
            Log.networkResponse(response: httpResponse, data: data)
            let statusCode = httpResponse?.statusCode ?? 400

            switch statusCode {
            case 200:
                return data
            default:
                throw NetworkDispatcherError.networkError(code: statusCode)
            }
        } catch let error {
            Log.error("Error in call: \(error)")
            throw error
        }
    }
    
}

