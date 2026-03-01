//
//  BookDetailViewModel.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 27.02.26.
//
import Foundation

final class BookDetailViewModel {

    private let service: AudiobookServiceProtocol
    private(set) var book: Audiobook

    // Gələcəkdə Aida tərəfindən dynamic doldurulacaq
    private(set) var aiSummary: [String] = []

    var onDataUpdated: (() -> Void)?
    var onError: ((String) -> Void)?

    init(book: Audiobook,
         service: AudiobookServiceProtocol = AudiobookService()) {
        self.book = book
        self.service = service
    }

    func fetchDetail() {
        service.fetchAudiobookDetail(id: book.id.value) { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let updatedBook):
                    self.book = updatedBook
                    self.generatePlaceholderSummary()
                    self.onDataUpdated?()
                case .failure:
                    self.onError?("Failed to load book detail")
                }
            }
        }
    }

    // MARK: - Computed

    var durationText: String {
        guard let sections = book.numSections?.value else { return "—" }
        return "\(sections) ch."
    }

    var languageText: String { "English" }

    var ratingText: String { "4.8" }
}

// MARK: - Private

private extension BookDetailViewModel {

    /// Ai da hazır olana qədər placeholder summary
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
