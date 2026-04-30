//
//  AsyncUseCase.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 30/04/2026.
//

import Foundation

protocol AsyncUseCase {
    associatedtype Output

    func execute() async throws -> Output
}

