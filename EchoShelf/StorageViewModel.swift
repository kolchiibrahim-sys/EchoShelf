//
//  StorageViewModel.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 07.03.26.
//

import Foundation
import UIKit

final class StorageCacheViewModel {

    var onBooksUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    var onSuccess: ((String) -> Void)?

    // MARK: - Data

    private(set) var books: [LibraryItem] = []

    // Device storage
    var totalBytes: Int64 {
        let attrs = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())
        return (attrs?[.systemSize] as? Int64) ?? 0
    }

    var freeBytes: Int64 {
        let attrs = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())
        return (attrs?[.systemFreeSize] as? Int64) ?? 0
    }

    var usedBytes: Int64 { totalBytes - freeBytes }

    var appBytes: Int64 {
        books.compactMap { item -> Int64? in
            guard let url = item.localURL else { return nil }
            let attrs = try? FileManager.default.attributesOfItem(atPath: url.path)
            return attrs?[.size] as? Int64
        }.reduce(0, +)
    }

    var cacheBytes: Int64 {
        let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
        guard let url = cacheURL else { return 0 }
        let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: [.fileSizeKey])
        var total: Int64 = 0
        while let fileURL = enumerator?.nextObject() as? URL {
            let size = (try? fileURL.resourceValues(forKeys: [.fileSizeKey]))?.fileSize ?? 0
            total += Int64(size)
        }
        return total
    }

    // MARK: - Formatted Strings

    func formatBytes(_ bytes: Int64) -> String {
        let gb = Double(bytes) / 1_073_741_824
        if gb >= 1 { return String(format: "%.1f GB", gb) }
        let mb = Double(bytes) / 1_048_576
        return String(format: "%.0f MB", mb)
    }

    var totalFormatted: String { formatBytes(totalBytes) }
    var freeFormatted: String { formatBytes(freeBytes) }
    var appFormatted: String { formatBytes(appBytes) }
    var cacheFormatted: String { formatBytes(cacheBytes) }

    var appRatio: Float {
        guard totalBytes > 0 else { return 0 }
        return Float(appBytes) / Float(totalBytes)
    }

    var otherRatio: Float {
        guard totalBytes > 0 else { return 0 }
        let other = usedBytes - appBytes
        return Float(max(0, other)) / Float(totalBytes)
    }

    // MARK: - Load

    func loadBooks() {
        books = LibraryManager.shared.loadAll().filter { $0.type == .ebook || $0.type == .kids }
        onBooksUpdated?()
    }

    // MARK: - Delete

    func deleteBook(id: String) {
        LibraryManager.shared.delete(id: id)
        loadBooks()
        onSuccess?("Kitab silindi.")
    }

    // MARK: - Clear Cache

    func clearCache() {
        let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
        guard let url = cacheURL else { return }
        do {
            let files = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
            for file in files {
                try? FileManager.default.removeItem(at: file)
            }
            onSuccess?("Keş təmizləndi.")
            onBooksUpdated?()
        } catch {
            onError?(error.localizedDescription)
        }
    }
}
