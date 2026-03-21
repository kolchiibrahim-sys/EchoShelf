//
//  GutendexModel.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 02.03.26.
//
import Foundation

struct GutendexResponse: Decodable {
    let count: Int
    let next: String?
    let results: [GutendexBook]
}

struct GutendexBook: Decodable {
    let id: Int
    let title: String
    let authors: [GutendexAuthor]
    let subjects: [String]
    let formats: [String: String]
    let downloadCount: Int

    enum CodingKeys: String, CodingKey {
        case id, title, authors, subjects, formats
        case downloadCount = "download_count"
    }

    var pdfURL: URL? {
        let pdfKeys = [
            "application/pdf",
            "application/pdf; charset=us-ascii"
        ]
        for key in pdfKeys {
            if let urlStr = formats[key] {
                let secure = urlStr.replacingOccurrences(of: "http://", with: "https://")
                if let url = URL(string: secure) { return url }
            }
        }
        return nil
    }

    var coverURL: URL? {
        guard let urlStr = formats["image/jpeg"] else { return nil }
        let secure = urlStr.replacingOccurrences(of: "http://", with: "https://")
        return URL(string: secure)
    }

    var authorName: String {
        authors.first.map { a in
            let parts = a.name.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            return parts.count == 2 ? "\(parts[1]) \(parts[0])" : a.name
        } ?? "Unknown Author"
    }
}

struct GutendexAuthor: Decodable {
    let name: String
    let birthYear: Int?
    let deathYear: Int?

    enum CodingKeys: String, CodingKey {
        case name
        case birthYear = "birth_year"
        case deathYear = "death_year"
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
        self.id           = String(book.id)
        self.title        = book.title
        self.authorName   = book.authorName
        self.coverURL     = book.coverURL
        self.pdfURL       = book.pdfURL
        self.subject      = book.subjects.first
        self.subjects     = book.subjects
        self.downloadCount = book.downloadCount
    }
    init(id: String, title: String, authorName: String,
         coverURL: URL?, pdfURL: URL?, subject: String?,
         subjects: [String] = [], downloadCount: Int) {
        self.id            = id
        self.title         = title
        self.authorName    = authorName
        self.coverURL      = coverURL
        self.pdfURL        = pdfURL
        self.subject       = subject
        self.subjects      = subjects
        self.downloadCount = downloadCount
    }
}
