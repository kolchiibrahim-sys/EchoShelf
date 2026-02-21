//
//  AudiobooksResponse.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 21.02.26.
//
import Foundation

struct AudiobooksResponse: Decodable {
    let books: [Audiobook]
}

struct Audiobook: Decodable {
    let id: FlexibleInt
    let title: String
    let description: String?
    let url_librivox: String?
    let url_zip_file: String?
    let numSections: FlexibleInt?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case url_librivox
        case url_zip_file
        case numSections = "num_sections"
    }
}
