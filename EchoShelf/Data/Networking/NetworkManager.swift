//
//  NetworkManager.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 21.02.26.
//
import Foundation
import Alamofire

final class NetworkManager {

    static let shared = NetworkManager()
    private init() {}

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
}

extension NetworkManager {

    func fetchArchiveCover(for book: Audiobook, completion: @escaping (URL?) -> Void) {
        guard let identifier = book.archiveIdentifier else {
            completion(book.archiveCoverURL)
            return
        }
        let url = URL(string: "https://archive.org/services/img/\(identifier)")
        completion(url)
    }
}
