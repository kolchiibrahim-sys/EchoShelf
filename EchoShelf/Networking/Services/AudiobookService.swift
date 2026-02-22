//
//  AudiobookService.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 21.02.26.
//
import Foundation

final class AudiobookService: AudiobookServiceProtocol {

    func fetchAudiobooks(
        page: Int,
        completion: @escaping (Result<[Audiobook], APIError>) -> Void
    ) {
        let endpoint = LibriVoxEndpoint.getAudiobooks(page: page)

        NetworkManager.shared.request(endpoint) { (result: Result<AudiobooksResponse, APIError>) in
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

        NetworkManager.shared.request(endpoint) { (result: Result<AudiobooksResponse, APIError>) in
            switch result {
            case .success(let response):
                completion(.success(response.books))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
