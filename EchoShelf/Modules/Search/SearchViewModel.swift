//
//  SearchViewModel.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 22.02.26.
//
import Foundation

final class SearchViewModel {

    private let audiobookService: AudiobookServiceProtocol
    private let ebookService: EbookServiceProtocol

    // Audiobooks
    private(set) var books: [Audiobook] = []
    private(set) var youMightLike: [Audiobook] = []

    // Ebooks
    private(set) var ebooks: [Ebook] = []
    private(set) var youMightLikeEbooks: [Ebook] = []

    private(set) var recentSearches: [String] = []
    private(set) var isLoading = false

    var onDataUpdated: (() -> Void)?
    var onError: ((String) -> Void)?

    init(
        audiobookService: AudiobookServiceProtocol = AudiobookService(),
        ebookService: EbookServiceProtocol = EbookService.shared
    ) {
        self.audiobookService = audiobookService
        self.ebookService = ebookService
        loadRecents()
        fetchSuggestions()
    }

    // MARK: - Search

    func search(query: String, tab: SearchTab) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            books = []; ebooks = []
            DispatchQueue.main.async { self.onDataUpdated?() }
            return
        }
        addRecent(trimmed)
        isLoading = true
        DispatchQueue.main.async { self.onDataUpdated?() }

        switch tab {
        case .audiobooks: searchAudiobooks(query: trimmed)
        case .books:      searchEbooks(query: trimmed)
        }
    }

    func searchByGenre(subject: String, displayTitle: String, tab: SearchTab) {
        isLoading = true
        DispatchQueue.main.async { self.onDataUpdated?() }

        switch tab {
        case .audiobooks:
            audiobookService.fetchByGenre(subject: subject, page: 0) { [weak self] result in
                guard let self else { return }
                DispatchQueue.main.async {
                    self.isLoading = false
                    if case .success(let b) = result { self.books = b }
                    else { self.books = []; self.onError?("Could not load \(displayTitle)") }
                    self.onDataUpdated?()
                }
            }
        case .books:
            ebookService.fetchEbooksBySubject(subject: subject, page: 0) { [weak self] result in
                guard let self else { return }
                DispatchQueue.main.async {
                    self.isLoading = false
                    if case .success(let b) = result { self.ebooks = b }
                    else { self.ebooks = []; self.onError?("Could not load \(displayTitle)") }
                    self.onDataUpdated?()
                }
            }
        }
    }

    // MARK: - Recents

    func deleteRecent(at index: Int) {
        guard index < recentSearches.count else { return }
        recentSearches.remove(at: index)
        saveRecents(); onDataUpdated?()
    }

    func clearRecents() {
        recentSearches.removeAll()
        saveRecents(); onDataUpdated?()
    }

    // MARK: - Computed (Audiobooks)

    var topResult: Audiobook? { books.first }

    var otherVersions: [Audiobook] {
        guard books.count > 1 else { return [] }
        return Array(books.dropFirst().prefix(5))
    }

    var relatedAuthors: [Author] {
        let authors = books.compactMap { $0.authors?.first }
        var unique: [Author] = []
        for a in authors where !unique.contains(where: { $0.firstName == a.firstName && $0.lastName == a.lastName }) {
            unique.append(a)
        }
        return Array(unique.prefix(6))
    }

    // MARK: - Computed (Ebooks)

    var topEbookResult: Ebook? { ebooks.first }

    var otherEbooks: [Ebook] {
        guard ebooks.count > 1 else { return [] }
        return Array(ebooks.dropFirst().prefix(5))
    }
}

// MARK: - Private

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
        if recentSearches.count > 5 { recentSearches.removeLast() }
        saveRecents()
    }

    func searchAudiobooks(query: String) {
        audiobookService.searchAudiobooks(query: query) { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                self.isLoading = false
                self.books = (try? result.get()) ?? []
                self.onDataUpdated?()
            }
        }
    }

    func searchEbooks(query: String) {
        ebookService.searchEbooks(query: query) { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                self.isLoading = false
                self.ebooks = (try? result.get()) ?? []
                self.onDataUpdated?()
            }
        }
    }

    func fetchSuggestions() {
        audiobookService.fetchAudiobooks(page: 1) { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                if case .success(let b) = result {
                    self.youMightLike = Array(b.prefix(8))
                    self.onDataUpdated?()
                }
            }
        }
        ebookService.fetchEbooksBySubject(subject: "fiction", page: 0) { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                if case .success(let b) = result {
                    self.youMightLikeEbooks = Array(b.prefix(8))
                    self.onDataUpdated?()
                }
            }
        }
    }
}
