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

        AF.request(endpoint.url,
                   method: endpoint.method,
                   parameters: endpoint.parameters)
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
