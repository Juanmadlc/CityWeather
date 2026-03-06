//
//  DateExtension.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 6/3/26.
//

import Foundation

extension Date {
    func toString(as format: DateFormat = .simpleDate,
                  for locale: String = Constants.Locale.esLocale) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: locale)
        dateFormatter.dateFormat = format.rawValue
        return dateFormatter.string(from: self)
    }
}


enum DateFormat: String {
    case simpleDate = "dd/MM/yyyy"
}


extension DateFormatter {
    static let emissionDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.locale = Locale(identifier: Constants.Locale.esLocale)
        return dateFormatter
    }()
}
