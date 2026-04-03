//
//  EbookService.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 02.03.26.
//
import Foundation
import Alamofire

/// Swift 6: JSON decode for Alamofire's nonisolated `responseData` callback (avoids main-actor `Decodable` isolation issues).
private enum GutendexHTTPDecoding {
    nonisolated static func decodeResponse(_ data: Data) throws -> GutendexResponse {
        try JSONDecoder().decode(GutendexResponse.self, from: data)
    }
}

protocol EbookServiceProtocol {
    func searchEbooks(query: String, completion: @escaping (Result<[Ebook],
                                                            APIError>) -> Void)
    func fetchEbooksBySubject(subject: String, page: Int, completion: @escaping (Result<[Ebook],
                                                                                 APIError>) -> Void)
}

final class EbookService: EbookServiceProtocol {

    static let shared = EbookService()
    private init() {}

    private let baseURL = "https://gutendex.com/books"

    func searchEbooks(query: String, completion: @escaping (Result<[Ebook],
                                                            APIError>) -> Void) {
        let params: [String: Any] = [
            "search": query,
            "mime_type": "application/pdf"
        ]

        AF.request(baseURL, parameters: params)
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        let result = try GutendexHTTPDecoding.decodeResponse(data)
                        let ebooks = result.results
                            .filter { $0.pdfURL != nil }
                            .map { Ebook(from: $0) }
                        completion(.success(ebooks))
                    } catch {
                        completion(.failure(.requestFailed))
                    }
                case .failure:
                    completion(.failure(.requestFailed))
                }
            }
    }


    func fetchEbooksBySubject(subject: String,
                              page: Int,
                              completion: @escaping (Result<[Ebook],
                                                     APIError>) -> Void) {
        let params: [String: Any] = [
            "topic": subject,
            "mime_type": "application/pdf",
            "page": page + 1
        ]

        AF.request(baseURL, parameters: params)
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        let result = try GutendexHTTPDecoding.decodeResponse(data)
                        let ebooks = result.results
                            .filter { $0.pdfURL != nil }
                            .map { Ebook(from: $0) }
                        completion(.success(ebooks))
                    } catch {
                        completion(.failure(.requestFailed))
                    }
                case .failure:
                    completion(.failure(.requestFailed))
                }
            }
    }
}
