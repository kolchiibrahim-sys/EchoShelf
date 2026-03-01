//
//  EbookService.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 01.03.26.
//
import Foundation
import Alamofire

protocol EbookServiceProtocol {
    func searchEbooks(query: String, completion: @escaping (Result<[Ebook], APIError>) -> Void)
    func fetchEbooksBySubject(subject: String, page: Int, completion: @escaping (Result<[Ebook], APIError>) -> Void)
    func fetchReadLinks(workKey: String, completion: @escaping (URL?) -> Void)
}

final class EbookService: EbookServiceProtocol {

    static let shared = EbookService()
    private init() {}

    private let baseURL = "https://openlibrary.org"

    // MARK: - Search

    func searchEbooks(query: String, completion: @escaping (Result<[Ebook], APIError>) -> Void) {
        let url = "\(baseURL)/search.json"
        let params: [String: Any] = [
            "q": query,
            "has_fulltext": "true",
            "limit": 20
        ]

        AF.request(url, parameters: params)
            .validate()
            .responseData { [weak self] response in
                guard let self else { return }
                switch response.result {
                case .success(let data):
                    do {
                        let result = try JSONDecoder().decode(OpenLibrarySearchResponse.self, from: data)
                        let ebooks = result.docs
                            .filter { $0.publicScanB == true || $0.hasFulltext == true }
                            .map { self.mapToEbook($0) }
                        completion(.success(ebooks))
                    } catch {
                        completion(.failure(.requestFailed))
                    }
                case .failure:
                    completion(.failure(.requestFailed))
                }
            }
    }

    // MARK: - Fetch by Subject

    func fetchEbooksBySubject(subject: String, page: Int = 0, completion: @escaping (Result<[Ebook], APIError>) -> Void) {
        let slug = subject.lowercased().replacingOccurrences(of: " ", with: "_")
        let url = "\(baseURL)/subjects/\(slug).json"
        let limit = 20
        let params: [String: Any] = [
            "limit": limit,
            "offset": page * limit,
            "ebooks": true
        ]

        AF.request(url, parameters: params)
            .validate()
            .responseData { [weak self] response in
                guard let self else { return }
                switch response.result {
                case .success(let data):
                    do {
                        let result = try JSONDecoder().decode(OLSubjectResponse.self, from: data)
                        let ebooks = result.works.map { self.mapSubjectWorkToEbook($0) }
                        completion(.success(ebooks))
                    } catch {
                        completion(.failure(.requestFailed))
                    }
                case .failure:
                    completion(.failure(.requestFailed))
                }
            }
    }

    // MARK: - Fetch Read Links

    func fetchReadLinks(workKey: String, completion: @escaping (URL?) -> Void) {
        let olid = workKey.replacingOccurrences(of: "/works/", with: "")
        let url = "https://archive.org/services/loans/loan/?action=availability&identifier=\(olid)"

        AF.request(url)
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    if let result = try? JSONDecoder().decode(OLAvailabilityResponse.self, from: data) {
                        if let epubUrl = result.formats?.epub?.url, let url = URL(string: epubUrl) {
                            completion(url)
                            return
                        }
                        if let pdfUrl = result.formats?.pdf?.url, let url = URL(string: pdfUrl) {
                            completion(url)
                            return
                        }
                    }
                    // Fallback: Open Library web reader
                    completion(URL(string: "https://openlibrary.org\(workKey)"))
                case .failure:
                    completion(URL(string: "https://openlibrary.org\(workKey)"))
                }
            }
    }
}

// MARK: - Mappers

private extension EbookService {

    func mapToEbook(_ doc: EbookDoc) -> Ebook {
        let coverURL: URL? = doc.coverId.flatMap {
            URL(string: "https://covers.openlibrary.org/b/id/\($0)-L.jpg")
        }
        return Ebook(
            id: doc.key,
            title: doc.title,
            authorName: doc.authorName?.first ?? "Unknown Author",
            coverURL: coverURL,
            publishYear: doc.firstPublishYear,
            subject: doc.subject?.first,
            epubURL: nil,
            pdfURL: nil
        )
    }

    func mapSubjectWorkToEbook(_ work: OLSubjectWork) -> Ebook {
        let coverURL: URL? = work.coverId.flatMap {
            URL(string: "https://covers.openlibrary.org/b/id/\($0)-L.jpg")
        }
        return Ebook(
            id: work.key,
            title: work.title,
            authorName: work.authors?.first?.name ?? "Unknown Author",
            coverURL: coverURL,
            publishYear: nil,
            subject: nil,
            epubURL: nil,
            pdfURL: nil
        )
    }
}

// MARK: - Subject Response Models

struct OLSubjectResponse: Decodable {
    let works: [OLSubjectWork]
}

struct OLSubjectWork: Decodable {
    let key: String
    let title: String
    let coverId: Int?
    let authors: [OLSubjectAuthor]?

    enum CodingKeys: String, CodingKey {
        case key, title
        case coverId = "cover_id"
        case authors
    }
}

struct OLSubjectAuthor: Decodable {
    let name: String
}
