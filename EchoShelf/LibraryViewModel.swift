//
//  LibraryViewModel.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 27.02.26.
//

import Foundation

final class LibraryViewModel {
    private(set) var ebooks:      [LibraryItem] = []
    private(set) var audiobooks:  [LibraryItem] = []
    private(set) var kidsBooks:   [LibraryItem] = []
    var onDataUpdated: (() -> Void)?
    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleLibraryUpdate),
            name: .libraryDidUpdate,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func loadLibrary() {
        let all  = LibraryManager.shared.loadAll()
        ebooks     = all.filter { $0.type == .ebook }
        audiobooks = all.filter { $0.type == .audiobook }
        kidsBooks  = all.filter { $0.type == .kids }
        onDataUpdated?()
    }

    func delete(_ item: LibraryItem) {
        LibraryManager.shared.delete(id: item.id)
    }
    var totalCount: Int { ebooks.count + audiobooks.count + kidsBooks.count }
    var isEmpty: Bool   { totalCount == 0 }

    func items(for section: LibrarySection) -> [LibraryItem] {
        switch section {
        case .ebooks:     return ebooks
        case .audiobooks: return audiobooks
        case .kidsBooks:  return kidsBooks
        }
    }

    func isEmpty(for section: LibrarySection) -> Bool {
        items(for: section).isEmpty
    }

    @objc private func handleLibraryUpdate() {
        DispatchQueue.main.async { [weak self] in
            self?.loadLibrary()
        }
    }
}

enum LibrarySection: Int, CaseIterable {
    case ebooks    = 0
    case audiobooks = 1
    case kidsBooks = 2

    var title: String {
        switch self {
        case .ebooks:     return "My Books"
        case .audiobooks: return "Audiobooks"
        case .kidsBooks:  return "Kids Books"
        }
    }

    var icon: String {
        switch self {
        case .ebooks:     return "book.fill"
        case .audiobooks: return "headphones"
        case .kidsBooks:  return "star.fill"
        }
    }
}
