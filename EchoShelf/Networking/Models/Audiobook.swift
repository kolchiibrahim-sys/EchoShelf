//
//  Audiobook.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 22.02.26.
//
import Foundation

struct Audiobook: Decodable {
    
    let id: FlexibleInt
    let title: String
    let authors: [Author]?
    let url_librivox: String?
    let url_zip_file: String?
    let url_iarchive: String?
    let url_rss: String?
    let url_cover_art: String?
    
    var authorName: String {
        authors?.first?.name ?? "Unknown Author"
    }
    var coverURL: String? {
        if let cover = url_cover_art, !cover.isEmpty {
            return cover
        }
        
        return "https://archive.org/services/img/\(id.value)"
    }
}
