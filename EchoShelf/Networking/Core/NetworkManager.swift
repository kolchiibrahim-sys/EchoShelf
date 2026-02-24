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

    // MARK: MAIN REQUEST
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

// MARK: GOOGLE BOOKS COVER FETCH
extension NetworkManager {
    
    func fetchGoogleCover(for book: Audiobook, completion: @escaping (URL?) -> Void) {
        
        let query = "\(book.title) \(book.authorName)"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        let urlString = "https://www.googleapis.com/books/v1/volumes?q=\(query)&maxResults=1"
        
        AF.request(urlString).responseJSON { response in
            
            guard
                let data = response.data,
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let items = json["items"] as? [[String: Any]],
                let volumeInfo = items.first?["volumeInfo"] as? [String: Any],
                let imageLinks = volumeInfo["imageLinks"] as? [String: Any],
                let thumbnail = imageLinks["thumbnail"] as? String,
                let httpsThumb = URL(string: thumbnail.replacingOccurrences(of: "http://", with: "https://"))
            else {
                completion(nil)
                return
            }
            
            completion(httpsThumb)
        }
    }
}
