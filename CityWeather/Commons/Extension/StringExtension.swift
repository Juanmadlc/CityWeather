//
//  StringExtension.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 6/3/26.
//

import Foundation

extension String {
    func localized() -> String {
        return NSLocalizedString(self, comment: "")
    }
}
