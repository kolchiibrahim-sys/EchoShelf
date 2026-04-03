//
//  GutendexModel.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 02.03.26.
//
import Foundation

// MARK: - Gutendex API (Decodable conformance in extensions with `nonisolated` for Swift 6 + Alamofire callbacks)

struct GutendexAuthor {
    let name: String
    let birthYear: Int?
    let deathYear: Int?
}

extension GutendexAuthor: Decodable {
    nonisolated init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy:
                                        CodingKeys.self)
        name = try c.decode(String.self,
                            forKey: .name)
        birthYear = try c.decodeIfPresent(Int.self,
                                          forKey: .birthYear)
        deathYear = try c.decodeIfPresent(Int.self,
                                          forKey: .deathYear)
    }

    private enum CodingKeys: String, CodingKey {
        case name
        case birthYear = "birth_year"
        case deathYear = "death_year"
    }
}

struct GutendexBook {
    let id: Int
    let title: String
    let authors: [GutendexAuthor]
    let subjects: [String]
    let formats: [String: String]
    let downloadCount: Int

    nonisolated var pdfURL: URL? {
        let pdfKeys = [
            "application/pdf",
            "application/pdf; charset=us-ascii"
        ]
        for key in pdfKeys {
            if let urlStr = formats[key] {
                let secure = urlStr.replacingOccurrences(of: "http://",
                                                         with: "https://")
                if let url = URL(string: secure) { return url }
            }
        }
        return nil
    }

    nonisolated var coverURL: URL? {
        guard let urlStr = formats["image/jpeg"] else { return nil }
        let secure = urlStr.replacingOccurrences(of: "http://",
                                                 with: "https://")
        return URL(string: secure)
    }

    nonisolated var authorName: String {
        authors.first.map { a in
            let parts = a.name.split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespaces) }
            return parts.count == 2 ? "\(parts[1]) \(parts[0])" : a.name
        } ?? "Unknown Author"
    }
}

extension GutendexBook: Decodable {
    nonisolated init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(Int.self, forKey: .id)
        title = try c.decode(String.self, forKey: .title)
        authors = try c.decode([GutendexAuthor].self, forKey: .authors)
        subjects = try c.decode([String].self, forKey: .subjects)
        formats = try c.decode([String: String].self, forKey: .formats)
        downloadCount = try c.decode(Int.self, forKey: .downloadCount)
    }

    private enum CodingKeys: String, CodingKey {
        case id, title, authors, subjects, formats
        case downloadCount = "download_count"
    }
}

struct GutendexResponse {
    let count: Int
    let next: String?
    let results: [GutendexBook]
}

extension GutendexResponse: Decodable {
    nonisolated init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        count = try c.decode(Int.self,
                             forKey: .count)
        next = try c.decodeIfPresent(String.self,
                                     forKey: .next)
        results = try c.decode([GutendexBook].self,
                               forKey: .results)
    }

    private enum CodingKeys: String, CodingKey {
        case count, next, results
    }
}

struct Ebook: Codable {
    let id: String
    let title: String
    let authorName: String
    let coverURL: URL?
    let pdfURL: URL?
    let subject: String?
    let subjects: [String]
    let downloadCount: Int

    var isReadable: Bool { pdfURL != nil }

    var isKids: Bool {
        let keywords = ["children", "juvenile", "kids", "picture books", "fairy tales"]
        return subjects.map { $0.lowercased() }.contains(where: { sub in
            keywords.contains(where: { sub.contains($0) })
        })
    }

    init(from book: GutendexBook) {
        self.id = String(book.id)
        self.title = book.title
        self.authorName = book.authorName
        self.coverURL = book.coverURL
        self.pdfURL = book.pdfURL
        self.subject = book.subjects.first
        self.subjects = book.subjects
        self.downloadCount = book.downloadCount
    }
    init(id: String,
         title: String,
         authorName: String,
         coverURL: URL?,
         pdfURL: URL?,
         subject: String?,
         subjects: [String] = [],
         downloadCount: Int) {
        self.id = id
        self.title = title
        self.authorName = authorName
        self.coverURL = coverURL
        self.pdfURL = pdfURL
        self.subject = subject
        self.subjects = subjects
        self.downloadCount = downloadCount
    }
}
