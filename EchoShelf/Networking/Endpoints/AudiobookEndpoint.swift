//
//  AudiobookEndpoint.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 24.02.26.
//
import Foundation
import Alamofire

enum AudiobookEndpoint: Endpoint {

    case getAudiobooks(page: Int)
    case search(query: String)
    case detail(id: Int)

    var baseURL: String {
        "https://librivox.org/api/feed/audiobooks"
    }

    var path: String { "" }

    var method: HTTPMethod { .get }

    var parameters: Parameters? {
        switch self {

        case .getAudiobooks(let page):
            return [
                "format": "json",
                "page": page
            ]

        case .search(let query):
            return [
                "format": "json",
                "title": query
            ]

        case .detail(let id):
            return [
                "format": "json",
                "id": id
            ]
        }
    }
}
