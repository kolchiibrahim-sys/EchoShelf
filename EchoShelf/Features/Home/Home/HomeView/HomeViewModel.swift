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

    private(set) var state: ViewState<Void> = .idle {
        didSet { onStateChanged?(state) }
    }

    private(set) var audiobooks: [Audiobook] = []
    private(set) var ebooks: [Ebook] = []
    private(set) var kidsEbooks: [Ebook] = []

    var onStateChanged: ((ViewState<Void>) -> Void)?

    var books: [Audiobook] { audiobooks }

    init(
        audiobookService: AudiobookServiceProtocol = AudiobookService(),
        ebookService: EbookServiceProtocol = EbookService.shared
    ) {
        self.audiobookService = audiobookService
        self.ebookService = ebookService
    }

    func fetchBooks() {
        state = .loading
        fetchAudiobooks()
        fetchEbooks()
        fetchKidsEbooks()
    }

    func fetchAudiobooks() {
        audiobookService.fetchAudiobooks(page: 1) { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let books):
                    self.audiobooks = books
                    self.state = .success(())
                case .failure(let error):
                    self.state = .failure(error)
                }
            }
        }
    }

    func fetchEbooks() {
        ebookService.fetchEbooksBySubject(subject: "fiction", page: 0) { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let books):
                    self.ebooks = books
                    self.state = .success(())
                case .failure(let error):
                    self.state = .failure(error)
                }
            }
        }
    }

    func fetchKidsEbooks() {
        ebookService.fetchEbooksBySubject(subject: "children", page: 0) { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let books):
                    self.kidsEbooks = books
                    self.state = .success(())
                case .failure(let error):
                    self.state = .failure(error)
                }
            }
        }
    }

    var trendingAudiobooks: [Audiobook] { Array(audiobooks.prefix(10)) }
    var recommendedAudiobooks: [Audiobook] { Array(audiobooks.dropFirst(10).prefix(10)) }

    var trendingEbooks: [Ebook] { Array(ebooks.prefix(10)) }
    var recommendedEbooks: [Ebook] { Array(ebooks.dropFirst(10).prefix(10)) }

    var trendingKidsEbooks: [Ebook] { Array(kidsEbooks.prefix(10)) }
    var recommendedKidsEbooks: [Ebook] { Array(kidsEbooks.dropFirst(10).prefix(10)) }
}
