//
//  AudibookEndpoint.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 22.02.26.
//
import Foundation
import Alamofire

enum AudiobookEndpoint: Endpoint {

    case search(query: String)
    case getAudiobooks(page: Int)

    var baseURL: String {
        "https://librivox.org/api/feed"
    }

    var path: String {
        switch self {

        case .search(let query):
            return "/audiobooks/title/^\(query)"

        case .getAudiobooks:
            return "/audiobooks"
        }
    }

    var method: HTTPMethod {
        .get
    }

    var parameters: Parameters? {
        switch self {

        case .search:
            return ["format": "json"]

        case .getAudiobooks(let page):
            return [
                "format": "json",
                "page": page
            ]
        }
    }
}
