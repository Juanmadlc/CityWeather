//
//  GeoCodingSearchCache.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 09/11/2026.
//

import Foundation

actor GeoCodingSearchCache {
    private struct Entry {
        let value: GeoCodingSearchWrapper
        let storedAt: Date
    }

    private var entries: [String: Entry] = [:]
    private let timeToLive: TimeInterval
    private let now: @Sendable () -> Date

    init(
        timeToLive: TimeInterval = Constants.Search.cacheTimeToLive,
        now: @escaping @Sendable () -> Date = Date.init
    ) {
        self.timeToLive = timeToLive
        self.now = now
    }

    func value(for query: String) -> GeoCodingSearchWrapper? {
        removeExpiredEntries()
        return entries[key(for: query)]?.value
    }

    func store(_ value: GeoCodingSearchWrapper, for query: String) {
        entries[key(for: query)] = Entry(value: value, storedAt: now())
    }

    private func removeExpiredEntries() {
        entries = entries.filter { isValid($0.value) }
    }

    private func isValid(_ entry: Entry) -> Bool {
        now().timeIntervalSince(entry.storedAt) < timeToLive
    }

    private func key(for query: String) -> String {
        query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}
