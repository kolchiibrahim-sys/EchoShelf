//
//  LibriVoxEndpoint.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 21.02.26.
//
import Foundation
import Alamofire

enum LibriVoxEndpoint: Endpoint {

    case getAudiobooks(page: Int)

    var baseURL: String {
        return "https://librivox.org/api/feed"
    }

    var path: String {
        return "/audiobooks"
    }

    var method: HTTPMethod {
        return .get
    }

    var parameters: Parameters? {
        switch self {
        case .getAudiobooks(let page):
            return [
                "format": "json",
                "limit": 20,
                            "offset": (page - 1) * 20
            ]
        }
    }
}
