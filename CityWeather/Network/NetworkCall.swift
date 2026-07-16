//
//  NetworkCall.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 6/3/26.
//

import Foundation

protocol NetworkCall {
    var path: URLComponents { get }
    var method: String { get }
    var headers: [String: String]? { get }
}

extension NetworkCall {
    func urlRequest(baseURL: String) throws -> URLRequest {
        Log.networkCall(path: path, method: method, headers: headers)

        guard let url = path.url else {
            throw NetworkError.urlNotFound(path.url?.absoluteString ?? "")
        }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.allHTTPHeaderFields = headers
        if method == HTTPMethod.post {
            request.httpBody = path.percentEncodedQuery?.data(using: .utf8)
        }
        Log.networkRequest(request: request)
        return request
    }
}

