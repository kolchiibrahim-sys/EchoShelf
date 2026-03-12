//
//  AudiobookService.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 21.02.26.
//
import Foundation
import Alamofire

final class AudiobookService: AudiobookServiceProtocol {

    func fetchAudiobooks(
        page: Int,
        completion: @escaping (Result<[Audiobook], APIError>) -> Void
    ) {
        let endpoint = AudiobookEndpoint.getAudiobooks(page: page)
        request(endpoint) { [weak self] (result: Result<AudiobooksResponse, APIError>) in
            guard let self else { return }
            switch result {
            case .success(let response):
                self.attachCovers(to: response.books, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func searchAudiobooks(
        query: String,
        completion: @escaping (Result<[Audiobook], APIError>) -> Void
    ) {
        let endpoint = AudiobookEndpoint.search(query: query)
        request(endpoint) { [weak self] (result: Result<AudiobooksResponse, APIError>) in
            guard let self else { return }
            switch result {
            case .success(let response):
                self.attachCovers(to: response.books, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func fetchAudiobookDetail(
        id: Int,
        completion: @escaping (Result<Audiobook, APIError>) -> Void
    ) {
        let endpoint = AudiobookEndpoint.detail(id: id)
        request(endpoint) { [weak self] (result: Result<AudiobooksResponse, APIError>) in
            guard let self else { return }
            switch result {
            case .success(let response):
                guard var book = response.books.first else {
                    completion(.failure(.invalidData))
                    return
                }
                book.coverURL = self.archiveCoverURL(for: book)
                completion(.success(book))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func fetchByGenre(
        subject: String,
        page: Int,
        completion: @escaping (Result<[Audiobook], APIError>) -> Void
    ) {
        let endpoint = AudiobookEndpoint.genre(subject: subject, page: page)
        request(endpoint) { [weak self] (result: Result<AudiobooksResponse, APIError>) in
            guard let self else { return }
            switch result {
            case .success(let response):
                self.attachCovers(to: response.books, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

private extension AudiobookService {

    func request<T: Decodable>(
        _ endpoint: Endpoint,
        completion: @escaping (Result<T, APIError>) -> Void
    ) {
        AF.request(endpoint.baseURL,
                   method: endpoint.method,
                   parameters: endpoint.parameters,
                   encoding: URLEncoding.default)
        .validate()
        .responseDecodable(of: T.self) { response in
            switch response.result {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                print("Network error:", error)
                completion(.failure(.requestFailed))
            }
        }
    }

    func archiveCoverURL(for book: Audiobook) -> URL? {
        guard let identifier = book.archiveIdentifier else {
            return book.archiveCoverURL
        }
        return URL(string: "https://archive.org/services/img/\(identifier)")
    }

    func attachCovers(
        to books: [Audiobook],
        completion: @escaping (Result<[Audiobook], APIError>) -> Void
    ) {
        var booksWithCovers = books
        for index in booksWithCovers.indices {
            booksWithCovers[index].coverURL = archiveCoverURL(for: booksWithCovers[index])
        }
        completion(.success(booksWithCovers))
    }
}
