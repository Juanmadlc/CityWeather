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
    
    func callAuth(endpoint: NetworkCall) async throws -> Data {
           do {
               var request = try endpoint.urlRequest(baseURL: baseURL)

               if let mobilityEndpoint = endpoint as? MobilityServicesRouter, case .incidents = mobilityEndpoint {
                   let username = "usu_app"
                   let password = Bundle.main.apiEnvironment == .pro ? Auth.pro : Auth.dev
                   let authStr = "\(username):\(password)"
                   if let authData = authStr.data(using: .utf8) {
                       let authValue = "Basic \(authData.base64EncodedString())"
                       request.setValue(authValue, forHTTPHeaderField: "Authorization")
                   }
               }

               let (data, response) = try await session.data(for: request)
               
               if let httpResponse = response as? HTTPURLResponse {
                   Log.networkResponse(response: httpResponse, data: data)
                   let statusCode = httpResponse.statusCode
                   Log.debug("HTTP Status Code: \(statusCode)")
                   
                   switch statusCode {
                   case 200:
                       return data
                   default:
                       throw NetworkDispatcherError.networkError(code: statusCode)
                   }
               } else {
                   throw NetworkDispatcherError.networkError(code: 400)
               }
           } catch let error {
               Log.error("Error in call: \(error)")
               throw error
           }
       }

}

