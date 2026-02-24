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

    func search(query: String) {

        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            books = []
            onDataUpdated?()
            return
        }

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
                    self.books = []
                    self.onError?("Search failed")
                    self.onDataUpdated?()
                }
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

        recentSearches.removeAll {
            $0.lowercased() == query.lowercased()
        }

        recentSearches.insert(query, at: 0)

        if recentSearches.count > 5 {
            recentSearches.removeLast()
        }

        saveRecents()
        onDataUpdated?()
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
