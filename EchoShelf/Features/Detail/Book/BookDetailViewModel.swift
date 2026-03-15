//
//  BookDetailViewModel.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 27.02.26.
//
import Foundation

extension Notification.Name {
    static let favoritesDidChange = Notification.Name("favoritesDidChange")
}

final class BookDetailViewModel {

    private let service: AudiobookServiceProtocol
    private(set) var book: Audiobook
    private let favoritesViewModel = FavoritesViewModel()

    private(set) var state: ViewState<Void> = .idle {
        didSet { onStateChanged?(state) }
    }

    private(set) var aiSummary: [String] = []

    var onStateChanged: ((ViewState<Void>) -> Void)?

    init(book: Audiobook, service: AudiobookServiceProtocol = AudiobookService()) {
        self.book = book
        self.service = service
    }

    func fetchDetail() {
        state = .loading
        service.fetchAudiobookDetail(id: book.id.value) { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let updatedBook):
                    self.book = updatedBook
                    self.generatePlaceholderSummary()
                    self.state = .success(())
                case .failure(let error):
                    self.state = .failure(error)
                }
            }
        }
    }

    func toggleFavorite(bookType: BookDetailType) {
        switch bookType {
        case .audiobook:
            favoritesViewModel.toggleBook(book)
        case .ebook(let ebook):
            if ebook.isKids {
                favoritesViewModel.toggleKidsBook(ebook)
            } else {
                favoritesViewModel.toggleEbook(ebook)
            }
        }
        NotificationCenter.default.post(name: .favoritesDidChange, object: nil)
    }

    func isFavorited(bookType: BookDetailType) -> Bool {
        switch bookType {
        case .audiobook:
            return favoritesViewModel.isBookFavorited(book)
        case .ebook(let ebook):
            return ebook.isKids
                ? favoritesViewModel.isKidsBookFavorited(ebook)
                : favoritesViewModel.isEbookFavorited(ebook)
        }
    }

    var durationText: String {
        guard let sections = book.numSections?.value else { return "—" }
        return "\(sections) ch."
    }

    var languageText: String { "English" }
    var ratingText: String { "4.8" }
}

private extension BookDetailViewModel {
    func generatePlaceholderSummary() {
        let title = book.title
        let author = book.authorName
        aiSummary = [
            "A compelling story by \(author) that draws readers into a unique world.",
            "\"\(title)\" explores themes of identity, purpose, and the human condition.",
            "Narrated with emotional depth, capturing every moment of the journey."
        ]
    }
}

final class EbookDetailViewModel {

    let ebook: Ebook
    private(set) var aiSummary: [String] = []
    private(set) var description: String = ""

    var onDataUpdated: (() -> Void)?

    init(ebook: Ebook) {
        self.ebook = ebook
        buildContent()
    }

    private func buildContent() {
        description = buildDescription()
        aiSummary   = buildAISummary()
        onDataUpdated?()
    }

    private func buildDescription() -> String {
        var parts: [String] = []
        if let subject = ebook.subject {
            parts.append("Genre: \(subject.capitalized)")
        }
        parts.append("\"\(ebook.title)\" is a classic work by \(ebook.authorName), available as a free ebook from Project Gutenberg.")
        if ebook.downloadCount > 0 {
            let formatted = formatDownloadCount(ebook.downloadCount)
            parts.append("This book has been downloaded \(formatted) times, making it one of the most popular titles in the public domain.")
        }
        return parts.joined(separator: "\n\n")
    }

    private func buildAISummary() -> [String] {
        let title  = ebook.title
        let author = ebook.authorName
        var points = [
            "Written by \(author), \"\(title)\" is a timeless classic that has captivated readers for generations.",
            "Freely available in the public domain — read it anytime, anywhere within the app."
        ]
        if let subject = ebook.subject {
            points.append("Categorized under \(subject.capitalized) — perfect for fans of the genre.")
        } else {
            points.append("A landmark work of literature that continues to inspire readers worldwide.")
        }
        return points
    }

    private func formatDownloadCount(_ count: Int) -> String {
        switch count {
        case 0..<1_000:  return "\(count)"
        case 0..<10_000: return String(format: "%.1fK", Double(count) / 1_000)
        default:         return String(format: "%.0fK", Double(count) / 1_000)
        }
    }
}
