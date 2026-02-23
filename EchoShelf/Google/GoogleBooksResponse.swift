//
//  GoogleBooksResponse.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 24.02.26.
//
import Foundation

struct GoogleBooksResponse: Decodable {
    let items: [GoogleBook]?
}

struct GoogleBook: Decodable {
    let volumeInfo: VolumeInfo?
}

struct VolumeInfo: Decodable {
    let imageLinks: ImageLinks?
}

struct ImageLinks: Decodable {
    let thumbnail: String?
}
