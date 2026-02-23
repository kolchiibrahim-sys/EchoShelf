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
    let id: String
    let title: String
    let description: String?
    let urlLibrivox: String?
    let urlRss: String?
    let authors: [Author]?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case urlLibrivox = "url_librivox"
        case urlRss = "url_rss"
        case authors
    }
}

struct Author: Decodable {
    let firstName: String?
    let lastName: String?

    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
    }
}
