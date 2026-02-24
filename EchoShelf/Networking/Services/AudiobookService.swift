//
//  AudiobookService.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 21.02.26.
//
import Foundation

final class AudiobookService: AudiobookServiceProtocol {

    private let network = NetworkManager.shared

    // MARK: FETCH LIST
    func fetchAudiobooks(
        page: Int,
        completion: @escaping (Result<[Audiobook], APIError>) -> Void
    ) {
        let endpoint = AudiobookEndpoint.getAudiobooks(page: page)

        network.request(endpoint) { [weak self] (result: Result<AudiobooksResponse, APIError>) in
            guard let self else { return }

            switch result {
            case .success(let response):
                self.attachCovers(to: response.books, completion: completion)

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: SEARCH
    func searchAudiobooks(
        query: String,
        completion: @escaping (Result<[Audiobook], APIError>) -> Void
    ) {
        let endpoint = AudiobookEndpoint.search(query: query)

        network.request(endpoint) { [weak self] (result: Result<AudiobooksResponse, APIError>) in
            guard let self else { return }

            switch result {
            case .success(let response):
                self.attachCovers(to: response.books, completion: completion)

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: DETAIL
    func fetchAudiobookDetail(
        id: Int,
        completion: @escaping (Result<Audiobook, APIError>) -> Void
    ) {
        let endpoint = AudiobookEndpoint.detail(id: id)

        network.request(endpoint) { [weak self] (result: Result<AudiobooksResponse, APIError>) in
            guard let self else { return }

            switch result {
            case .success(let response):
                guard var book = response.books.first else {
                    completion(.failure(.invalidData))
                    return
                }

                self.network.fetchGoogleCover(for: book) { url in
                    book.googleCoverURL = url
                    completion(.success(book))
                }

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

// MARK: COVER ATTACH HELPER
private extension AudiobookService {

    func attachCovers(
        to books: [Audiobook],
        completion: @escaping (Result<[Audiobook], APIError>) -> Void
    ) {
        var booksWithCovers = books
        let group = DispatchGroup()

        for index in books.indices {
            group.enter()

            network.fetchGoogleCover(for: books[index]) { url in
                booksWithCovers[index].googleCoverURL = url
                group.leave()
            }
        }

        group.notify(queue: .main) {
            completion(.success(booksWithCovers))
        }
    }
}
