//
//  HomeViewModel.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 21.02.26.
//
import Foundation

final class HomeViewModel {

    private let service: AudiobookServiceProtocol
    private(set) var books: [Audiobook] = []

    var onDataUpdated: (() -> Void)?
    var onError: ((String) -> Void)?

    init(service: AudiobookServiceProtocol = AudiobookService()) {
        self.service = service
    }

    func fetchBooks() {

        service.fetchAudiobooks(page: 1) { [weak self] result in
            guard let self else { return }

            switch result {

            case .success(let books):

                print("Librivox books loaded:", books.count)

                var booksWithCovers = books
                let group = DispatchGroup()

                for index in booksWithCovers.indices {
                    group.enter()

                    let title = booksWithCovers[index].title
                    print("Searching cover for:", title)

                    GoogleBooksService.shared.fetchCover(title: title) { url in
                        print("cover found:", url ?? "nil")
                        booksWithCovers[index].googleCoverURL = url
                        group.leave()
                    }
                }

                group.notify(queue: .main) {
                    self.books = booksWithCovers
                    self.onDataUpdated?()
                }

            case .failure(let error):
                DispatchQueue.main.async {
                    self.onError?("Failed to load books")
                    print("error:", error)
                }
            }
        }
    }
}
