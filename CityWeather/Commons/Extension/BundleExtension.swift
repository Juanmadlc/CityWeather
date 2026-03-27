//
//  BundleExtension.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 27/3/26.
//

import Foundation

extension Bundle {
    var apiEnvironment: EnvironmentKind {
        get {
            let preferences = self.preferences
            guard let value = preferences?["Api environment"] as? String else { return .dev }
            return .init(rawValue: value) ?? .dev
        }
        set {
            var data: [String: Any] = self.preferences ?? .init()
            data["Api environment"] = newValue.rawValue
            guard let plistData = try? PropertyListSerialization.data(
                fromPropertyList: data,
                format: .xml,
                options: 0
            ) else { return }
            guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                return
            }
            let fileURL = directory.appendingPathComponent("Preferences.plist")
            do {
                try plistData.write(to: fileURL)
            } catch {
                print(error)
            }
        }
    }

    var preferences: [String: Any]? {
        guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        let url: URL? = {
            let fileUrl = directory.appendingPathComponent("Preferences.plist")
            guard !FileManager.default.fileExists(atPath: fileUrl.path) else {
                return fileUrl
            }

            guard let path = self.path(forResource: "Preferences", ofType: "plist") else { return nil }
            return .init(fileURLWithPath: path)
        }()
        guard let url, let data = try? Data(contentsOf: url) else { return nil }
        do {
            return try PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any]
        } catch {
            print(error)
            return nil
        }
    }
}
