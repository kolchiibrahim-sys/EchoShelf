//
//  AudiobookService.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 21.02.26.
//
import Foundation

final class AudiobookService: AudiobookServiceProtocol {

    private let network = NetworkManager.shared

    func fetchAudiobooks(
        page: Int,
        completion: @escaping (Result<[Audiobook], APIError>) -> Void
    ) {
        let endpoint = AudiobookEndpoint.getAudiobooks(page: page)

        network.request(endpoint) { (result: Result<AudiobooksResponse, APIError>) in
            switch result {
            case .success(let response):
                completion(.success(response.books))
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

        network.request(endpoint) { (result: Result<AudiobooksResponse, APIError>) in
            switch result {
            case .success(let response):
                completion(.success(response.books))
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

        network.request(endpoint) { (result: Result<AudiobooksResponse, APIError>) in
            switch result {
            case .success(let response):
                guard let book = response.books.first else {
                    completion(.failure(.invalidData))
                    return
                }
                completion(.success(book))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
