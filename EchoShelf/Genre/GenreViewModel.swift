//
//  GenreViewModel.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 02.03.26.
//
import Foundation

enum GenreTab {
    case audiobooks
    case books
}

final class GenreViewModel {

    // MARK: - Properties

    let genre: String

    private let audiobookService: AudiobookServiceProtocol
    private let ebookService: EbookServiceProtocol

    // Audiobooks
    private(set) var audiobooks: [Audiobook] = []
    private var audiobookPage = 0
    private(set) var isLoadingAudiobooks = false
    private(set) var hasMoreAudiobooks = true

    // Ebooks
    private(set) var ebooks: [Ebook] = []
    private var ebookPage = 0
    private(set) var isLoadingEbooks = false
    private(set) var hasMoreEbooks = true

    // MARK: - Callbacks

    var onDataUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    var onLoadingChanged: (() -> Void)?

    // MARK: - Init

    init(
        genre: String,
        audiobookService: AudiobookServiceProtocol = AudiobookService(),
        ebookService: EbookServiceProtocol = EbookService.shared
    ) {
        self.genre = genre
        self.audiobookService = audiobookService
        self.ebookService = ebookService
    }

    // MARK: - Fetch

    func fetchInitial() {
        fetchAudiobooks(reset: true)
        fetchEbooks()
    }

    // MARK: - Audiobooks (pagination)

    func fetchAudiobooks(reset: Bool = false) {
        guard !isLoadingAudiobooks, hasMoreAudiobooks || reset else { return }

        if reset {
            audiobookPage = 0
            audiobooks = []
            hasMoreAudiobooks = true
        }

        isLoadingAudiobooks = true
        onLoadingChanged?()

        audiobookService.fetchByGenre(subject: genre, page: audiobookPage) { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                self.isLoadingAudiobooks = false
                switch result {
                case .success(let books):
                    if books.isEmpty {
                        self.hasMoreAudiobooks = false
                    } else {
                        self.audiobooks.append(contentsOf: books)
                        self.audiobookPage += 1
                    }
                    self.onDataUpdated?()
                    self.onLoadingChanged?()
                case .failure:
                    self.onError?("Failed to load audiobooks")
                    self.onLoadingChanged?()
                }
            }
        }
    }

    func fetchNextAudiobookPage() {
        fetchAudiobooks(reset: false)
    }

    // MARK: - Ebooks (Open Library subject)

    func fetchEbooks(reset: Bool = false) {
        guard !isLoadingEbooks, hasMoreEbooks || reset else { return }

        if reset {
            ebookPage = 0
            ebooks = []
            hasMoreEbooks = true
        }

        isLoadingEbooks = true
        onLoadingChanged?()

        ebookService.fetchEbooksBySubject(subject: genre, page: ebookPage) { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                self.isLoadingEbooks = false
                switch result {
                case .success(let books):
                    if books.isEmpty {
                        self.hasMoreEbooks = false
                    } else {
                        self.ebooks.append(contentsOf: books)
                        self.ebookPage += 1
                    }
                    self.onDataUpdated?()
                    self.onLoadingChanged?()
                case .failure:
                    self.onError?("Failed to load books")
                    self.onLoadingChanged?()
                }
            }
        }
    }

    func fetchNextEbookPage() {
        fetchEbooks(reset: false)
    }

    // MARK: - Helpers

    func items(for tab: GenreTab) -> Int {
        tab == .audiobooks ? audiobooks.count : ebooks.count
    }

    func isLoading(for tab: GenreTab) -> Bool {
        tab == .audiobooks ? isLoadingAudiobooks : isLoadingEbooks
    }

    func hasMore(for tab: GenreTab) -> Bool {
        tab == .audiobooks ? hasMoreAudiobooks : hasMoreEbooks
    }

    func shouldFetchNextPage(for tab: GenreTab, at index: Int) -> Bool {
        switch tab {
        case .audiobooks:
            let threshold = audiobooks.count - 4
            return index >= threshold && hasMoreAudiobooks && !isLoadingAudiobooks
        case .books:
            let threshold = ebooks.count - 4
            return index >= threshold && hasMoreEbooks && !isLoadingEbooks
        }
    }
}
