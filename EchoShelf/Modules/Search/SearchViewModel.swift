//
//  SearchViewModel.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 22.02.26.
//
import Foundation

final class SearchViewModel {

    private let service: AudiobookServiceProtocol
    private(set) var books: [Audiobook] = []
    private(set) var recentSearches: [String] = []

    var onDataUpdated: (() -> Void)?
    var onError: ((String) -> Void)?

    init(service: AudiobookServiceProtocol = AudiobookService()) {
        self.service = service
        loadRecents()
    }

    // MARK: Search
    func search(query: String) {

        guard !query.isEmpty else { return }

        addRecent(query)

        service.searchAudiobooks(query: query) { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let books):
                self.books = books
                DispatchQueue.main.async {
                    self.onDataUpdated?()
                }

            case .failure:
                DispatchQueue.main.async {
                    self.onError?("Search failed")
                }
            }
        }
    }
}
extension SearchViewModel {

    private var recentsKey: String { "recent_searches" }

    private func loadRecents() {
        recentSearches = UserDefaults.standard.stringArray(forKey: recentsKey) ?? []
    }

    private func saveRecents() {
        UserDefaults.standard.set(recentSearches, forKey: recentsKey)
    }

    private func addRecent(_ query: String) {
        recentSearches.removeAll { $0.lowercased() == query.lowercased() }
        recentSearches.insert(query, at: 0)

        if recentSearches.count > 5 {
            recentSearches.removeLast()
        }

        saveRecents()
    }

    func deleteRecent(at index: Int) {
        recentSearches.remove(at: index)
        saveRecents()
        onDataUpdated?()
    }

    func clearAllRecents() {
        recentSearches.removeAll()
        saveRecents()
        onDataUpdated?()
    }
}
