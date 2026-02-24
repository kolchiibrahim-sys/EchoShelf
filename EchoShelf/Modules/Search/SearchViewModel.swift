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

    private(set) var isLoading = false

    var onDataUpdated: (() -> Void)?
    var onError: ((String) -> Void)?

    init(service: AudiobookServiceProtocol = AudiobookService()) {
        self.service = service
        loadRecents()
    }

    // MARK: SEARCH

    func search(query: String) {

        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            books = []
            DispatchQueue.main.async { self.onDataUpdated?() }
            return
        }

        addRecent(trimmed)

        isLoading = true
        DispatchQueue.main.async { self.onDataUpdated?() }

        service.searchAudiobooks(query: trimmed) { [weak self] result in
            guard let self else { return }

            DispatchQueue.main.async {

                self.isLoading = false

                switch result {
                case .success(let books):
                    self.books = books

                case .failure:
                    self.books = []
                    self.onError?("Search failed")
                }

                self.onDataUpdated?()
            }
        }
    }
}
private extension SearchViewModel {

    var recentsKey: String { "recent_searches" }

    func loadRecents() {
        recentSearches = UserDefaults.standard.stringArray(forKey: recentsKey) ?? []
    }

    func saveRecents() {
        UserDefaults.standard.set(recentSearches, forKey: recentsKey)
    }

    func addRecent(_ query: String) {

        recentSearches.removeAll { $0.lowercased() == query.lowercased() }
        recentSearches.insert(query, at: 0)

        if recentSearches.count > 5 {
            recentSearches.removeLast()
        }

        saveRecents()
    }
}
extension SearchViewModel {

    var topResult: Audiobook? {
        books.first
    }

    var otherVersions: [Audiobook] {
        guard books.count > 1 else { return [] }
        return Array(books.dropFirst().prefix(5))
    }

    var relatedAuthors: [Author] {

        let authors = books.compactMap { $0.authors?.first }

        var unique: [Author] = []

        for author in authors {
            if !unique.contains(where: {
                $0.firstName == author.firstName &&
                $0.lastName == author.lastName
            }) {
                unique.append(author)
            }
        }

        return Array(unique.prefix(6))
    }
}
