//
//  Audiobook.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 22.02.26.
//
import Foundation

struct AudiobooksResponse: Decodable {
    let books: [Audiobook]
}

struct Audiobook: Decodable {

    let id: FlexibleInt
    let title: String
    let description: String?
    let urlLibrivox: String?
    let urlRss: String?
    let numSections: FlexibleInt?
    let authors: [Author]?

    // 🔥 ƏN VACİB SƏTR — STORED PROPERTY
    var coverURL: URL?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case urlLibrivox = "url_librivox"
        case urlRss = "url_rss"
        case numSections = "num_sections"
        case authors
    }
}

struct Author: Decodable {
    let firstName: String?
    let lastName: String?

    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName  = "last_name"
    }
}

// MARK: Helpers
extension Audiobook {

    var authorName: String {
        guard let author = authors?.first else { return "Unknown Author" }
        let full = "\(author.firstName ?? "") \(author.lastName ?? "")"
            .trimmingCharacters(in: .whitespaces)
        return full.isEmpty ? "Unknown Author" : full
    }
}
