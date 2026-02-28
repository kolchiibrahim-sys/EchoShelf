//
//  AllBooksViewModel.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 28.02.26.
//
import Foundation

enum AllBooksType {
    case trending
    case recommended

    var title: String {
        switch self {
        case .trending:    return "Trending Today"
        case .recommended: return "Recommended For You"
        }
    }
}

final class AllBooksViewModel {
    let type: AllBooksType
    private(set) var books: [Audiobook] = []
    private(set) var isLoading = false
    private(set) var hasMore = true

    var onDataUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    private let service: AudiobookServiceProtocol
    private var currentPage = 1
    private let pageSize = 20

    init(type: AllBooksType, service: AudiobookServiceProtocol = AudiobookService()) {
        self.type = type
        self.service = service
    }

    func fetchBooks() {
        guard !isLoading, hasMore else { return }
        isLoading = true

        service.fetchAudiobooks(page: currentPage) { [weak self] result in
            guard let self else { return }

            DispatchQueue.main.async {
                self.isLoading = false

                switch result {
                case .success(let newBooks):
                    if newBooks.isEmpty {
                        self.hasMore = false
                    } else {
                        self.books.append(contentsOf: newBooks)
                        self.currentPage += 1
                        if newBooks.count < self.pageSize {
                            self.hasMore = false
                        }
                    }
                    self.onDataUpdated?()

                case .failure:
                    self.onError?("Kitablar yüklənmədi. Yenidən cəhd edin.")
                }
            }
        }
    }

    func reset() {
        books = []
        currentPage = 1
        hasMore = true
        isLoading = false
    }
}
