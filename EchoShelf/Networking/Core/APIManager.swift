//
//  APIManager.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 21.02.26.
//
import Foundation
import Alamofire

final class APIManager: NetworkServiceProtocol {

    static let shared = APIManager()
    private init() {}

    func request<T: Decodable>(
        _ endpoint: Endpoint,
        completion: @escaping (Result<T, APIError>) -> Void
    ) {

        AF.request(
            endpoint.baseURL + endpoint.path,
            method: endpoint.method,
            parameters: endpoint.parameters,
            encoding: URLEncoding.default
        )
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
