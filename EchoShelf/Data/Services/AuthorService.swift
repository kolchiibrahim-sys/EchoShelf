//
//  AuthorService.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 23.03.26.
//
import Foundation
import Alamofire

struct OpenLibraryAuthor: nonisolated Decodable {
    let key: String
    let name: String
    let birthDate: String?
    let bio: OpenLibraryBio?

    enum CodingKeys: String, CodingKey {
        case key, name
        case birthDate = "birth_date"
        case bio
    }
}

enum OpenLibraryBio: Decodable {
    case string(String)
    case object(String)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let str = try? container.decode(String.self) {
            self = .string(str)
        } else {
            let obj = try container.decode([String: String].self)
            self = .object(obj["value"] ?? "")
        }
    }

    var text: String {
        switch self {
        case .string(let s):
            return s
        case .object(let s):
            return s
        }
    }
}

struct OpenLibrarySearchResponse: nonisolated Decodable {
    let docs: [OpenLibrarySearchDoc]
}

struct OpenLibrarySearchDoc: Decodable {
    let key: String
    let name: String
}

struct AuthorDetail {
    let firstName: String?
    let lastName: String?
    let photoURL: URL?
    let bio: String?
    let olid: String?

    var fullName: String {
        let full = "\(firstName ?? "") \(lastName ?? "")".trimmingCharacters(in: .whitespaces)
        return full.isEmpty ? "Unknown Author" : full
    }
}

final class AuthorService {
    static let shared = AuthorService()
    private init() {}

    private let openLibraryBase = "https://openlibrary.org"
    private let librivoxBase = "https://librivox.org/api/feed"

    func fetchAuthorDetail(
        firstName: String?,
        lastName: String?,
        completion: @escaping (AuthorDetail) -> Void
    ) {
        let name = "\(firstName ?? "") \(lastName ?? "")".trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else {
            completion(AuthorDetail(firstName: firstName,
                                    lastName: lastName,
                                    photoURL: nil,
                                    bio: nil,
                                    olid: nil))
            return
        }

        let searchURL = "\(openLibraryBase)/search/authors.json"
        AF.request(searchURL, parameters: ["q": name])
            .validate()
            .responseDecodable(of: OpenLibrarySearchResponse.self) { [weak self] response in
                guard let self else { return }
                guard let doc = try? response.result.get().docs.first else {
                    completion(AuthorDetail(firstName: firstName,
                                            lastName: lastName,
                                            photoURL: nil,
                                            bio: nil, olid: nil))
                    return
                }

                let olid = doc.key.replacingOccurrences(of: "/authors/", with: "")
                let photoURL = URL(string: "https://covers.openlibrary.org/a/olid/\(olid)-L.jpg")

                self.fetchBio(olid: olid) { bio in
                    completion(AuthorDetail(
                        firstName: firstName,
                        lastName: lastName,
                        photoURL: photoURL,
                        bio: bio,
                        olid: olid
                    ))
                }
            }
    }

    func fetchAuthorBooks(
        firstName: String?,
        lastName: String?,
        completion: @escaping ([Audiobook]) -> Void
    ) {
        var params: [String: Any] = ["format": "json", "limit": 20]
        if let first = firstName { params["first_name"] = first }
        if let last = lastName  { params["last_name"] = last }

        AF.request("\(librivoxBase)/audiobooks", parameters: params)
            .validate()
            .responseDecodable(of: AudiobooksResponse.self) { response in
                let books = (try? response.result.get().books) ?? []
                completion(books)
            }
    }

    private func fetchBio(olid: String, completion: @escaping (String?) -> Void) {
        let url = "\(openLibraryBase)/authors/\(olid).json"
        AF.request(url)
            .validate()
            .responseDecodable(of: OpenLibraryAuthor.self) { response in
                let bio = (try? response.result.get().bio)?.text
                completion(bio)
            }
    }
}
