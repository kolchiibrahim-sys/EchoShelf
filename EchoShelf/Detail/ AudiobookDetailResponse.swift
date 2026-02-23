//
//   AudiobookDetailResponse.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 24.02.26.
//
import Foundation

struct AudiobookDetailResponse: Decodable {
    let id: FlexibleInt
    let title: String
    let description: String?
    let url_librivox: String?
    let url_cover_art: String?
    let authors: [Author]?
}
