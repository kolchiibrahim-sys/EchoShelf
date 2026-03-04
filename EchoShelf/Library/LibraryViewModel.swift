//
//  LibraryViewModel.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 27.02.26.
//

import Foundation

final class LibraryViewModel {

    // MARK: - Data

    private(set) var ebooks:    [LibraryItem] = []
    private(set) var kidsBooks: [LibraryItem] = []

    // MARK: - Callbacks

    var onDataUpdated: (() -> Void)?

    // MARK: - Init

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

    // MARK: - Load

    func loadLibrary() {
        let all  = LibraryManager.shared.loadAll()
        ebooks    = all.filter { $0.type == .ebook }
        kidsBooks = all.filter { $0.type == .kids  }
        onDataUpdated?()
    }

    // MARK: - Delete

    func delete(_ item: LibraryItem) {
        LibraryManager.shared.delete(id: item.id)
        // loadLibrary notification ile tetiklenir
    }

    // MARK: - Computed

    var totalCount: Int { ebooks.count + kidsBooks.count }
    var isEmpty: Bool   { totalCount == 0 }

    func items(for section: LibrarySection) -> [LibraryItem] {
        switch section {
        case .ebooks:    return ebooks
        case .kidsBooks: return kidsBooks
        }
    }

    func isEmpty(for section: LibrarySection) -> Bool {
        items(for: section).isEmpty
    }

    // MARK: - Private

    @objc private func handleLibraryUpdate() {
        DispatchQueue.main.async { [weak self] in
            self?.loadLibrary()
        }
    }
}

// MARK: - Section Enum

enum LibrarySection: Int, CaseIterable {
    case ebooks    = 0
    case kidsBooks = 1

    var title: String {
        switch self {
        case .ebooks:    return "My Books"
        case .kidsBooks: return "Kids Books"
        }
    }

    var icon: String {
        switch self {
        case .ebooks:    return "book.fill"
        case .kidsBooks: return "star.fill"
        }
    }
}
