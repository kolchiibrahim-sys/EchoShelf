//
//  GoogleBooksService.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 24.02.26.
//
import Foundation
final class GoogleBooksService {

    static let shared = GoogleBooksService()
    private init() {}

    private var apiKey: String {
        SecretsManager.shared.googleAPIKey
    }

    func fetchCover(title: String, completion: @escaping (String?) -> Void) {

        print("Searching cover for:", title)

        let query = title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

        let urlString =
        "https://www.googleapis.com/books/v1/volumes?q=\(query)&maxResults=1&key=\(apiKey)"

        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in

            if let http = response as? HTTPURLResponse {
                print("Google status:", http.statusCode)
            }

            guard let data else {
                DispatchQueue.main.async { completion(nil) }
                return
            }

            do {
                let result = try JSONDecoder().decode(GoogleBooksResponse.self, from: data)

                let cover = result.items?
                    .first?
                    .volumeInfo?
                    .imageLinks?
                    .thumbnail?
                    .replacingOccurrences(of: "http://", with: "https://")

                print("cover found:", cover ?? "nil")

                DispatchQueue.main.async {
                    completion(cover)
                }

            } catch {
                print("Google decode error:", error)
                DispatchQueue.main.async {
                    completion(nil)
                }
            }

        }.resume()
    }
}
