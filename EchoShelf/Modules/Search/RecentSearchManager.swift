//
//  RecentSearchManager.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 24.02.26.
//
import Foundation

extension Notification.Name {
    static let recentsUpdated = Notification.Name("recentsUpdated")
}

final class RecentSearchManager {

    static let shared = RecentSearchManager()
    private init() {}

    private let key = "recent_searches"
    private let limit = 5

    var searches: [String] {
        UserDefaults.standard.stringArray(forKey: key) ?? []
    }

    func add(_ query: String) {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        var items = searches
        items.removeAll { $0.lowercased() == query.lowercased() }
        items.insert(query, at: 0)

        if items.count > limit {
            items = Array(items.prefix(limit))
        }

        save(items)
    }

    func delete(at index: Int) {
        var items = searches
        guard items.indices.contains(index) else { return }
        items.remove(at: index)
        save(items)
    }

    func clearAll() {
        UserDefaults.standard.removeObject(forKey: key)
        NotificationCenter.default.post(name: .recentsUpdated, object: nil)
    }

    private func save(_ items: [String]) {
        UserDefaults.standard.set(items, forKey: key)
        NotificationCenter.default.post(name: .recentsUpdated, object: nil)
    }
}
