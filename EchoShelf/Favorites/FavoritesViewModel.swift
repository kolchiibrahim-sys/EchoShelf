//
//  FavoritesViewModel.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 01.03.26.
//
import Foundation

final class FavoritesViewModel {

    private(set) var favoriteBooks:      [Audiobook] = []
    private(set) var favoriteAudiobooks: [Audiobook] = []
    private(set) var favoriteAuthors:    [Author]    = []
    private(set) var favoriteGenres:     [String]    = []

    var onDataUpdated: (() -> Void)?
    var onError: ((String) -> Void)?

    private let booksKey   = "favorite_books"
    private let authorsKey = "favorite_authors"
    private let genresKey  = "favorite_genres"

    init() {
        loadFromStorage()
    }

    func items(for section: FavoriteSection) -> Int {
        switch section {
        case .books:      return favoriteBooks.count
        case .audiobooks: return favoriteAudiobooks.count
        case .authors:    return favoriteAuthors.count
        case .genres:     return favoriteGenres.count
        }
    }

    func isEmpty(for section: FavoriteSection) -> Bool {
        items(for: section) == 0
    }

    func toggleBook(_ book: Audiobook, isAudiobook: Bool = false) {
        if isAudiobook {
            if let idx = favoriteAudiobooks.firstIndex(where: { $0.id.value == book.id.value }) {
                favoriteAudiobooks.remove(at: idx)
            } else {
                favoriteAudiobooks.insert(book, at: 0)
            }
        } else {
            if let idx = favoriteBooks.firstIndex(where: { $0.id.value == book.id.value }) {
                favoriteBooks.remove(at: idx)
            } else {
                favoriteBooks.insert(book, at: 0)
            }
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

    func isBookFavorited(_ book: Audiobook, isAudiobook: Bool = false) -> Bool {
        let list = isAudiobook ? favoriteAudiobooks : favoriteBooks
        return list.contains(where: { $0.id.value == book.id.value })
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

private extension FavoritesViewModel {

    func saveToStorage() {
        if let booksData = try? JSONEncoder().encode(favoriteBooks) {
            UserDefaults.standard.set(booksData, forKey: booksKey)
        }
        if let audiobooksData = try? JSONEncoder().encode(favoriteAudiobooks) {
            UserDefaults.standard.set(audiobooksData, forKey: booksKey + "_audio")
        }
        if let authorsData = try? JSONEncoder().encode(favoriteAuthors) {
            UserDefaults.standard.set(authorsData, forKey: authorsKey)
        }
        UserDefaults.standard.set(favoriteGenres, forKey: genresKey)
    }

    func loadFromStorage() {
        if let data = UserDefaults.standard.data(forKey: booksKey),
           let books = try? JSONDecoder().decode([Audiobook].self, from: data) {
            favoriteBooks = books
        }
        if let data = UserDefaults.standard.data(forKey: booksKey + "_audio"),
           let books = try? JSONDecoder().decode([Audiobook].self, from: data) {
            favoriteAudiobooks = books
        }
        if let data = UserDefaults.standard.data(forKey: authorsKey),
           let authors = try? JSONDecoder().decode([Author].self, from: data) {
            favoriteAuthors = authors
        }
        favoriteGenres = UserDefaults.standard.stringArray(forKey: genresKey) ?? []
    }
}

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
