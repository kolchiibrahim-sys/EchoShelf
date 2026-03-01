import Foundation
import Alamofire

enum AudiobookEndpoint: Endpoint {

    case getAudiobooks(page: Int)
    case search(query: String)
    case detail(id: Int)
    case genre(subject: String, page: Int)

    var baseURL: String {
        "https://librivox.org/api/feed/audiobooks/"
    }

    var path: String { "" }

    var method: HTTPMethod { .get }

    var parameters: Parameters? {
        switch self {

        case .getAudiobooks(let page):
            return [
                "format": "json",
                "limit": 20,
                "offset": page * 20
            ]

        case .search(let query):
            return [
                "format": "json",
                "title": "^\(query)",
                "limit": 20,
                "offset": 0
            ]

        case .detail(let id):
            return [
                "format": "json",
                "id": id
            ]

        case .genre(let subject, let page):
            return [
                "format": "json",
                "subject": subject,
                "limit": 20,
                "offset": page * 20
            ]
        }
    }
}
