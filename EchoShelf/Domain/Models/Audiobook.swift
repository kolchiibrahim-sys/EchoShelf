import Foundation

struct AudiobooksResponse: Decodable {
    let books: [Audiobook]
}

struct Audiobook: Decodable {

    let id: FlexibleInt
    let title: String
    let description: String?
    let urlLibrivox: String?
    let urlRss: String?
    let urlZipFile: String?
    let numSections: FlexibleInt?
    let authors: [Author]?
    var coverURL: URL?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case urlLibrivox = "url_librivox"
        case urlRss      = "url_rss"
        case urlZipFile  = "url_zip_file"
        case numSections = "num_sections"
        case authors
    }
}

struct Author: Decodable {
    let firstName: String?
    let lastName: String?

    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName  = "last_name"
    }
}

extension Audiobook {

    var authorName: String {
        guard let author = authors?.first else { return "Unknown Author" }
        let full = "\(author.firstName ?? "") \(author.lastName ?? "")"
            .trimmingCharacters(in: .whitespaces)
        return full.isEmpty ? "Unknown Author" : full
    }

    var archiveIdentifier: String? {
        guard let zip = urlZipFile,
              let url = URL(string: zip),
              url.host == "archive.org" else { return nil }
        let components = url.pathComponents
        guard components.count >= 3 else { return nil }
        let candidate = components[2]
        let blacklist = ["compress", "download", "stream"]
        guard !blacklist.contains(candidate.lowercased()) else { return nil }

        return candidate
    }

    var archiveCoverURL: URL? {
        guard let id = archiveIdentifier else { return nil }
        return URL(string: "https://archive.org/services/img/\(id)")
    }
}

