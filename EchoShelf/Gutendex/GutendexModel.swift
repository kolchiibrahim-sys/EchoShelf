//
//  GutendexModel.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 02.03.26.
//
import Foundation

// MARK: - API Response

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
    let formats: [String: String]   // mime type → URL
    let downloadCount: Int

    enum CodingKeys: String, CodingKey {
        case id, title, authors, subjects, formats
        case downloadCount = "download_count"
    }

    // PDF URL-i birbaşa qaytarır
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

    // Cover image
    var coverURL: URL? {
        guard let urlStr = formats["image/jpeg"] else { return nil }
        let secure = urlStr.replacingOccurrences(of: "http://", with: "https://")
        return URL(string: secure)
    }

    var authorName: String {
        authors.first.map { a in
            // "Austen, Jane" → "Jane Austen"
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

// MARK: - App Model

struct Ebook: Codable {
    let id: String
    let title: String
    let authorName: String
    let coverURL: URL?
    let pdfURL: URL?
    let subject: String?
    let downloadCount: Int

    var isReadable: Bool { pdfURL != nil }

    init(from book: GutendexBook) {
        self.id           = String(book.id)
        self.title        = book.title
        self.authorName   = book.authorName
        self.coverURL     = book.coverURL
        self.pdfURL       = book.pdfURL
        self.subject      = book.subjects.first
        self.downloadCount = book.downloadCount
    }

    // Manuel init (FavoritesViewModel üçün)
    init(id: String, title: String, authorName: String,
         coverURL: URL?, pdfURL: URL?, subject: String?, downloadCount: Int) {
        self.id            = id
        self.title         = title
        self.authorName    = authorName
        self.coverURL      = coverURL
        self.pdfURL        = pdfURL
        self.subject       = subject
        self.downloadCount = downloadCount
    }
}
