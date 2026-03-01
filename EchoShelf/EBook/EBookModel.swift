//
//  EbookModel.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 01.03.26.
//
import Foundation

// MARK: - Open Library Search Response

struct OpenLibrarySearchResponse: Decodable {
    let docs: [EbookDoc]
    let numFound: Int

    enum CodingKeys: String, CodingKey {
        case docs
        case numFound = "num_found"
    }
}

struct EbookDoc: Decodable {
    let key: String              // "/works/OL45883W"
    let title: String
    let authorName: [String]?
    let coverId: Int?
    let firstPublishYear: Int?
    let language: [String]?
    let subject: [String]?
    let hasFulltext: Bool?
    let publicScanB: Bool?       // true = tam oxuna bilər

    enum CodingKeys: String, CodingKey {
        case key, title
        case authorName      = "author_name"
        case coverId         = "cover_i"
        case firstPublishYear = "first_publish_year"
        case language, subject
        case hasFulltext     = "has_fulltext"
        case publicScanB     = "public_scan_b"
    }
}

// MARK: - Ebook (app-wide model)

struct Ebook: Codable {
    let id: String               // Open Library work key
    let title: String
    let authorName: String
    let coverURL: URL?
    let publishYear: Int?
    let subject: String?
    let epubURL: URL?
    let pdfURL: URL?
    var isReadable: Bool { epubURL != nil || pdfURL != nil }
}

// MARK: - Open Library Availability Response

struct OLAvailabilityResponse: Decodable {
    let status: String?
    let ebookAccess: String?
    let formats: OLFormats?

    enum CodingKeys: String, CodingKey {
        case status
        case ebookAccess = "ebook_access"
        case formats
    }
}

struct OLFormats: Decodable {
    let epub: OLFormatItem?
    let pdf: OLFormatItem?
}

struct OLFormatItem: Decodable {
    let url: String?
}
