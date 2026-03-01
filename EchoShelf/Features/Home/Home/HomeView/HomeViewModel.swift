//
//  HomeViewModel.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 21.02.26.
//
import Foundation

enum HomeTab {
    case audiobooks
    case books
}

final class HomeViewModel {

    private let audiobookService: AudiobookServiceProtocol
    private let ebookService: EbookServiceProtocol

    // Audiobooks
    private(set) var audiobooks: [Audiobook] = []

    // Ebooks
    private(set) var ebooks: [Ebook] = []

    var onDataUpdated: (() -> Void)?
    var onError: ((String) -> Void)?

    // Legacy — bəzi yerlər hələ books istifadə edir
    var books: [Audiobook] { audiobooks }

    init(
        audiobookService: AudiobookServiceProtocol = AudiobookService(),
        ebookService: EbookServiceProtocol = EbookService.shared
    ) {
        self.audiobookService = audiobookService
        self.ebookService = ebookService
    }

    // MARK: - Fetch

    func fetchBooks() {
        fetchAudiobooks()
        fetchEbooks()
    }

    func fetchAudiobooks() {
        audiobookService.fetchAudiobooks(page: 1) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let books):
                DispatchQueue.main.async {
                    self.audiobooks = books
                    self.onDataUpdated?()
                }
            case .failure:
                DispatchQueue.main.async {
                    self.onError?("Failed to load audiobooks")
                }
            }
        }
    }

    func fetchEbooks() {
        ebookService.fetchEbooksBySubject(subject: "fiction") { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let books):
                DispatchQueue.main.async {
                    self.ebooks = books
                    self.onDataUpdated?()
                }
            case .failure:
                DispatchQueue.main.async {
                    self.onError?("Failed to load books")
                }
            }
        }
    }

    // MARK: - Computed

    var trendingAudiobooks: [Audiobook] { Array(audiobooks.prefix(10)) }
    var recommendedAudiobooks: [Audiobook] { Array(audiobooks.dropFirst(10).prefix(10)) }

    var trendingEbooks: [Ebook] { Array(ebooks.prefix(10)) }
    var recommendedEbooks: [Ebook] { Array(ebooks.dropFirst(10).prefix(10)) }
}
