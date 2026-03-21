//
//  LibraryManager.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 05.03.26.
//

import Foundation

final class LibraryManager {

    static let shared = LibraryManager()
    private init() {}

    private let storageKey = "library_items_v1"

    @discardableResult
    func saveBook(from ebook: Ebook, pdfData: Data) throws -> LibraryItem {
        let fileName = buildFileName(id: ebook.id, title: ebook.title)
        let fileURL  = documentsURL.appendingPathComponent(fileName)

        try pdfData.write(to: fileURL, options: .atomic)

        let item = LibraryItem(from: ebook, localPDFPath: fileName)
        upsert(item)
        return item
    }

    func saveAudiobook(_ book: Audiobook) {
        let item = LibraryItem(from: book)
        upsert(item)
    }

    func delete(id: String) {
        var items = loadAll(includeDeleted: true)
        if let item = items.first(where: { $0.id == id }),
           let url = item.localURL {
            try? FileManager.default.removeItem(at: url)
        }
        items.removeAll { $0.id == id }
        persist(items)
        NotificationCenter.default.post(name: .libraryDidUpdate, object: nil)
    }

    func updateProgress(id: String, page: Int, total: Int) {
        var items = loadAll(includeDeleted: true)
        guard let idx = items.firstIndex(where: { $0.id == id }) else { return }
        items[idx].lastReadPage = page
        items[idx].totalPages   = total
        persist(items)
    }

    func isDownloaded(id: String) -> Bool {
        loadAll().contains { $0.id == id }
    }

    func loadAll(includeDeleted: Bool = false) -> [LibraryItem] {
        guard let data  = UserDefaults.standard.data(forKey: storageKey),
              let items = try? JSONDecoder().decode([LibraryItem].self, from: data)
        else { return [] }
        return includeDeleted ? items : items.filter { $0.isFileExists }
    }

    func item(id: String) -> LibraryItem? {
        loadAll().first { $0.id == id }
    }

    private var documentsURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private func upsert(_ item: LibraryItem) {
        var items = loadAll(includeDeleted: true)
        items.removeAll { $0.id == item.id }
        items.insert(item, at: 0)
        persist(items)
        NotificationCenter.default.post(name: .libraryDidUpdate, object: nil)
    }

    private func persist(_ items: [LibraryItem]) {
        guard let data = try? JSONEncoder().encode(items) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    private func buildFileName(id: String, title: String) -> String {
        let safe = title
            .components(separatedBy: .init(charactersIn: "/:*?\"<>|\\"))
            .joined(separator: "_")
        let short = String(safe.prefix(40))
        return "\(id)_\(short).pdf"
    }
}

extension Notification.Name {
    static let libraryDidUpdate = Notification.Name("libraryDidUpdate")
}
