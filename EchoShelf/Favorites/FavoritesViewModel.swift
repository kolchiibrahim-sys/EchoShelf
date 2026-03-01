//
//  FavoritesViewModel.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 01.03.26.
//
import Foundation

final class FavoritesViewModel {

    // MARK: - Data

    private(set) var favoriteBooks:      [Audiobook] = []   // LibriVox audiobooks
    var favoriteAudiobooks: [Audiobook] { favoriteBooks }   // eyni data
    private(set) var favoriteEbooks:     [Ebook]     = []   // Open Library ebooks
    private(set) var favoriteAuthors:    [Author]    = []
    private(set) var favoriteGenres:     [String]    = []

    // MARK: - Callbacks

    var onDataUpdated: (() -> Void)?
    var onError: ((String) -> Void)?

    // MARK: - Persistence Keys

    private let booksKey   = "favorite_books"
    private let ebooksKey  = "favorite_ebooks"
    private let authorsKey = "favorite_authors"
    private let genresKey  = "favorite_genres"

    // MARK: - Init

    init() {
        loadFromStorage()
    }

    // MARK: - Current Section Data

    func items(for section: FavoriteSection) -> Int {
        switch section {
        case .books:      return favoriteEbooks.count
        case .audiobooks: return favoriteBooks.count
        case .authors:    return favoriteAuthors.count
        case .genres:     return favoriteGenres.count
        }
    }

    func isEmpty(for section: FavoriteSection) -> Bool {
        items(for: section) == 0
    }

    // MARK: - Toggle Favorites

    func toggleBook(_ book: Audiobook) {
        if let idx = favoriteBooks.firstIndex(where: { $0.id.value == book.id.value }) {
            favoriteBooks.remove(at: idx)
        } else {
            favoriteBooks.insert(book, at: 0)
        }
        saveToStorage()
        onDataUpdated?()
    }

    func toggleEbook(_ ebook: Ebook) {
        if let idx = favoriteEbooks.firstIndex(where: { $0.id == ebook.id }) {
            favoriteEbooks.remove(at: idx)
        } else {
            favoriteEbooks.insert(ebook, at: 0)
        }
        saveToStorage()
        onDataUpdated?()
    }

    func toggleAuthor(_ author: Author) {
        if let idx = favoriteAuthors.firstIndex(where: {
            $0.firstName == author.firstName && $0.lastName == author.lastName
        }) {
            favoriteAuthors.remove(at: idx)
        } else {
            favoriteAuthors.insert(author, at: 0)
        }
        saveToStorage()
        onDataUpdated?()
    }

    func toggleGenre(_ genre: String) {
        if let idx = favoriteGenres.firstIndex(of: genre) {
            favoriteGenres.remove(at: idx)
        } else {
            favoriteGenres.insert(genre, at: 0)
        }
        saveToStorage()
        onDataUpdated?()
    }

    // MARK: - Check

    func isBookFavorited(_ book: Audiobook) -> Bool {
        favoriteBooks.contains(where: { $0.id.value == book.id.value })
    }

    func isEbookFavorited(_ ebook: Ebook) -> Bool {
        favoriteEbooks.contains(where: { $0.id == ebook.id })
    }

    func isAuthorFavorited(_ author: Author) -> Bool {
        favoriteAuthors.contains(where: {
            $0.firstName == author.firstName && $0.lastName == author.lastName
        })
    }

    func isGenreFavorited(_ genre: String) -> Bool {
        favoriteGenres.contains(genre)
    }
}

// MARK: - Persistence (UserDefaults + Codable)

private extension FavoritesViewModel {

    func saveToStorage() {
        if let d = try? JSONEncoder().encode(favoriteBooks)   { UserDefaults.standard.set(d, forKey: booksKey) }
        if let d = try? JSONEncoder().encode(favoriteEbooks)  { UserDefaults.standard.set(d, forKey: ebooksKey) }
        if let d = try? JSONEncoder().encode(favoriteAuthors) { UserDefaults.standard.set(d, forKey: authorsKey) }
        UserDefaults.standard.set(favoriteGenres, forKey: genresKey)
    }

    func loadFromStorage() {
        if let d = UserDefaults.standard.data(forKey: booksKey),
           let v = try? JSONDecoder().decode([Audiobook].self, from: d) { favoriteBooks = v }
        if let d = UserDefaults.standard.data(forKey: ebooksKey),
           let v = try? JSONDecoder().decode([Ebook].self, from: d) { favoriteEbooks = v }
        if let d = UserDefaults.standard.data(forKey: authorsKey),
           let v = try? JSONDecoder().decode([Author].self, from: d) { favoriteAuthors = v }
        favoriteGenres = UserDefaults.standard.stringArray(forKey: genresKey) ?? []
    }
}

// MARK: - Section Enum (ViewController ilə paylaşılır)

enum FavoriteSection: Int, CaseIterable {
    case books      = 0
    case audiobooks = 1
    case authors    = 2
    case genres     = 3

    var title: String {
        switch self {
        case .books:      return "Books"
        case .audiobooks: return "Audiobooks"
        case .authors:    return "Authors"
        case .genres:     return "Genres"
        }
    }

    var icon: String {
        switch self {
        case .books:      return "book.fill"
        case .audiobooks: return "headphones"
        case .authors:    return "person.fill"
        case .genres:     return "square.grid.2x2.fill"
        }
    }
}
