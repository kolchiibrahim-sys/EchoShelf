//
//  FavoritesViewModel.swift
//  EchoShelf
//
import Foundation
import FirebaseFirestore
import FirebaseAuth

final class FavoritesViewModel {

    private(set) var favoriteBooks:     [Audiobook] = []
    var favoriteAudiobooks: [Audiobook] { favoriteBooks }
    private(set) var favoriteEbooks:    [Ebook]     = []
    private(set) var favoriteKidsBooks: [Ebook]     = []
    private(set) var favoriteAuthors:   [Author]    = []
    private(set) var favoriteGenres:    [String]    = []

    var onDataUpdated: (() -> Void)?
    var onError: ((String) -> Void)?

    private let booksKey   = "favorite_books"
    private let ebooksKey  = "favorite_ebooks"
    private let kidsKey    = "favorite_kids_books"
    private let authorsKey = "favorite_authors"
    private let genresKey  = "favorite_genres"

    private let db = Firestore.firestore()
    private var uid: String? { Auth.auth().currentUser?.uid }

    init() {
        loadFromLocal()
        syncFromFirebase()
    }

    func items(for section: FavoriteSection) -> Int {
        switch section {
        case .books:      return favoriteEbooks.count
        case .audiobooks: return favoriteBooks.count
        case .kids:       return favoriteKidsBooks.count
        case .authors:    return favoriteAuthors.count
        case .genres:     return favoriteGenres.count
        }
    }

    func isEmpty(for section: FavoriteSection) -> Bool { items(for: section) == 0 }

    func reloadFromLocal() {
        loadFromLocal()
    }

    func toggleBook(_ book: Audiobook) {
        if let idx = favoriteBooks.firstIndex(where: { $0.id.value == book.id.value }) {
            favoriteBooks.remove(at: idx)
        } else {
            favoriteBooks.insert(book, at: 0)
        }
        saveToLocal()
        syncToFirebase()
        onDataUpdated?()
    }

    func toggleEbook(_ ebook: Ebook) {
        if let idx = favoriteEbooks.firstIndex(where: { $0.id == ebook.id }) {
            favoriteEbooks.remove(at: idx)
        } else {
            favoriteEbooks.insert(ebook, at: 0)
        }
        saveToLocal()
        syncToFirebase()
        onDataUpdated?()
    }

    func toggleKidsBook(_ ebook: Ebook) {
        if let idx = favoriteKidsBooks.firstIndex(where: { $0.id == ebook.id }) {
            favoriteKidsBooks.remove(at: idx)
        } else {
            favoriteKidsBooks.insert(ebook, at: 0)
        }
        saveToLocal()
        syncToFirebase()
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
        saveToLocal()
        syncToFirebase()
        onDataUpdated?()
    }

    func toggleGenre(_ genre: String) {
        if let idx = favoriteGenres.firstIndex(of: genre) {
            favoriteGenres.remove(at: idx)
        } else {
            favoriteGenres.insert(genre, at: 0)
        }
        saveToLocal()
        syncToFirebase()
        onDataUpdated?()
    }

    func isBookFavorited(_ book: Audiobook) -> Bool {
        favoriteBooks.contains(where: { $0.id.value == book.id.value })
    }

    func isEbookFavorited(_ ebook: Ebook) -> Bool {
        favoriteEbooks.contains(where: { $0.id == ebook.id })
    }

    func isKidsBookFavorited(_ ebook: Ebook) -> Bool {
        favoriteKidsBooks.contains(where: { $0.id == ebook.id })
    }

    func isAuthorFavorited(_ author: Author) -> Bool {
        favoriteAuthors.contains(where: {
            $0.firstName == author.firstName && $0.lastName == author.lastName
        })
    }

    func isGenreFavorited(_ genre: String) -> Bool { favoriteGenres.contains(genre) }
}

private extension FavoritesViewModel {

    func saveToLocal() {
        if let d = try? JSONEncoder().encode(favoriteBooks)     { UserDefaults.standard.set(d, forKey: booksKey) }
        if let d = try? JSONEncoder().encode(favoriteEbooks)    { UserDefaults.standard.set(d, forKey: ebooksKey) }
        if let d = try? JSONEncoder().encode(favoriteKidsBooks) { UserDefaults.standard.set(d, forKey: kidsKey) }
        if let d = try? JSONEncoder().encode(favoriteAuthors)   { UserDefaults.standard.set(d, forKey: authorsKey) }
        UserDefaults.standard.set(favoriteGenres, forKey: genresKey)
    }

    func loadFromLocal() {
        if let d = UserDefaults.standard.data(forKey: booksKey),
           let v = try? JSONDecoder().decode([Audiobook].self, from: d)  { favoriteBooks = v }
        if let d = UserDefaults.standard.data(forKey: ebooksKey),
           let v = try? JSONDecoder().decode([Ebook].self, from: d)      { favoriteEbooks = v }
        if let d = UserDefaults.standard.data(forKey: kidsKey),
           let v = try? JSONDecoder().decode([Ebook].self, from: d)      { favoriteKidsBooks = v }
        if let d = UserDefaults.standard.data(forKey: authorsKey),
           let v = try? JSONDecoder().decode([Author].self, from: d)     { favoriteAuthors = v }
        favoriteGenres = UserDefaults.standard.stringArray(forKey: genresKey) ?? []
    }
}

extension FavoritesViewModel {

    func syncToFirebase() {
        guard let uid else { return }
        guard
            let booksData   = try? JSONEncoder().encode(favoriteBooks),
            let ebooksData  = try? JSONEncoder().encode(favoriteEbooks),
            let kidsData    = try? JSONEncoder().encode(favoriteKidsBooks),
            let authorsData = try? JSONEncoder().encode(favoriteAuthors)
        else { return }

        let payload: [String: Any] = [
            "favoriteBooks":     booksData.base64EncodedString(),
            "favoriteEbooks":    ebooksData.base64EncodedString(),
            "favoriteKidsBooks": kidsData.base64EncodedString(),
            "favoriteAuthors":   authorsData.base64EncodedString(),
            "favoriteGenres":    favoriteGenres,
            "updatedAt":         FieldValue.serverTimestamp()
        ]
        db.collection("users").document(uid).setData(payload, merge: true)
    }

    func syncFromFirebase() {
        guard let uid else { return }
        db.collection("users").document(uid).getDocument { [weak self] snapshot, error in
            guard let self, let data = snapshot?.data(), error == nil else { return }
            if let str = data["favoriteBooks"] as? String,
               let d = Data(base64Encoded: str),
               let v = try? JSONDecoder().decode([Audiobook].self, from: d) { self.favoriteBooks = v }
            if let str = data["favoriteEbooks"] as? String,
               let d = Data(base64Encoded: str),
               let v = try? JSONDecoder().decode([Ebook].self, from: d) { self.favoriteEbooks = v }
            if let str = data["favoriteKidsBooks"] as? String,
               let d = Data(base64Encoded: str),
               let v = try? JSONDecoder().decode([Ebook].self, from: d) { self.favoriteKidsBooks = v }
            if let str = data["favoriteAuthors"] as? String,
               let d = Data(base64Encoded: str),
               let v = try? JSONDecoder().decode([Author].self, from: d) { self.favoriteAuthors = v }
            if let genres = data["favoriteGenres"] as? [String] { self.favoriteGenres = genres }
            self.saveToLocal()
            DispatchQueue.main.async { self.onDataUpdated?() }
        }
    }
}

enum FavoriteSection: Int, CaseIterable {
    case books      = 0
    case audiobooks = 1
    case kids       = 2
    case authors    = 3
    case genres     = 4

    var title: String {
        switch self {
        case .books:      return "Books"
        case .audiobooks: return "Audiobooks"
        case .kids:       return "Kids"
        case .authors:    return "Authors"
        case .genres:     return "Genres"
        }
    }

    var icon: String {
        switch self {
        case .books:      return "book.fill"
        case .audiobooks: return "headphones"
        case .kids:       return "star.fill"
        case .authors:    return "person.fill"
        case .genres:     return "square.grid.2x2.fill"
        }
    }
}
