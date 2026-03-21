//
//  LibraryItem.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 05.03.26.
//

import Foundation

struct LibraryItem: Codable, Identifiable {

    let id: String
    let title: String
    let author: String
    let coverURLString: String?
    let localPDFPath: String
    let downloadedAt: Date
    var lastReadPage: Int
    var totalPages: Int
    var type: LibraryItemType

    enum LibraryItemType: String, Codable {
        case ebook
        case audiobook
        case kids
    }

    var coverURL: URL? {
        guard let str = coverURLString else { return nil }
        return URL(string: str)
    }

    var localURL: URL? {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent(localPDFPath)
    }

    var isFileExists: Bool {
        if type == .audiobook { return true }
        guard let url = localURL else { return false }
        return FileManager.default.fileExists(atPath: url.path)
    }

    var readingProgress: Float {
        guard totalPages > 0 else { return 0 }
        return Float(lastReadPage) / Float(totalPages)
    }

    var progressText: String {
        guard totalPages > 0 else { return "Not started" }
        if lastReadPage == 0 { return "Not started" }
        if lastReadPage >= totalPages - 1 { return "Finished" }
        let percent = Int(readingProgress * 100)
        return "\(percent)% read"
    }
}

extension LibraryItem {
    init(from book: Audiobook) {
        self.id             = String(book.id.value)
        self.title          = book.title
        self.author         = book.authorName
        self.coverURLString = book.coverURL?.absoluteString
        self.localPDFPath   = ""
        self.downloadedAt   = Date()
        self.lastReadPage   = 0
        self.totalPages     = 0
        self.type           = .audiobook
    }
}

extension LibraryItem {
    init(from ebook: Ebook, localPDFPath: String) {
        self.id             = ebook.id
        self.title          = ebook.title
        self.author         = ebook.authorName
        self.coverURLString = ebook.coverURL?.absoluteString
        self.localPDFPath   = localPDFPath
        self.downloadedAt   = Date()
        self.lastReadPage   = 0
        self.totalPages     = 0
        let kidsKeywords = ["children", "juvenile", "kids", "picture books", "fairy tales"]
        let allSubjects  = ebook.subjects.map { $0.lowercased() }
        let isKids = allSubjects.contains(where: { sub in
            kidsKeywords.contains(where: { sub.contains($0) })
        })
        self.type = isKids ? .kids : .ebook
    }
}
