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
    case kids
}

final class HomeViewModel {

    private let audiobookService: AudiobookServiceProtocol
    private let ebookService: EbookServiceProtocol

    // Audiobooks
    private(set) var audiobooks: [Audiobook] = []

    // Ebooks
    private(set) var ebooks: [Ebook] = []

    // Kids
    private(set) var kidsEbooks: [Ebook] = []

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
        fetchKidsEbooks()
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
        ebookService.fetchEbooksBySubject(subject: "fiction", page: 0) { [weak self] result in
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

    func fetchKidsEbooks() {
        ebookService.fetchEbooksBySubject(subject: "children", page: 0) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let books):
                DispatchQueue.main.async {
                    self.kidsEbooks = books
                    self.onDataUpdated?()
                }
            case .failure:
                DispatchQueue.main.async {
                    self.onError?("Failed to load kids books")
                }
            }
        }
    }

    // MARK: - Computed

    var trendingAudiobooks: [Audiobook] { Array(audiobooks.prefix(10)) }
    var recommendedAudiobooks: [Audiobook] { Array(audiobooks.dropFirst(10).prefix(10)) }

    var trendingEbooks: [Ebook] { Array(ebooks.prefix(10)) }
    var recommendedEbooks: [Ebook] { Array(ebooks.dropFirst(10).prefix(10)) }

    var trendingKidsEbooks: [Ebook] { Array(kidsEbooks.prefix(10)) }
    var recommendedKidsEbooks: [Ebook] { Array(kidsEbooks.dropFirst(10).prefix(10)) }
}
