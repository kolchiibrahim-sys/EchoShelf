//
//  AudibookEndpoint.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 22.02.26.
//

import Foundation
import Alamofire

struct AudiobookEndpoint: Endpoint {

    var baseURL: String { "https://api.storytel.net" }

    var path: String
    var method: HTTPMethod
    var parameters: Parameters?

}
extension AudiobookEndpoint {

    static func audiobooks(page: Int) -> AudiobookEndpoint {
        return AudiobookEndpoint(
            path: "/search",
            method: .get,
            parameters: [
                "page": page,
                "pageSize": 20
            ]
        )
    }
}
extension AudiobookEndpoint {

    static func search(query: String) -> AudiobookEndpoint {
        return AudiobookEndpoint(
            path: "/search",
            method: .get,
            parameters: [
                "query": query,
                "page": 1,
                "pageSize": 20
            ]
        )
    }
}
