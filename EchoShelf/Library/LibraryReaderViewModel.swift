//
//  LibraryReaderViewModel.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 05.03.26.
//

import Foundation
import PDFKit

enum LibraryReaderState {
    case loading
    case ready(PDFDocument)
    case error(String)
}

final class LibraryReaderViewModel {

    // MARK: - Properties

    let item: LibraryItem

    private(set) var state: LibraryReaderState = .loading
    private(set) var currentPage: Int
    private(set) var totalPages:  Int
    private(set) var scaleFactor: CGFloat = 1.0

    // MARK: - Callbacks

    var onStateChanged:    ((LibraryReaderState) -> Void)?
    var onProgressChanged: ((Int, Int) -> Void)?

    // MARK: - Init

    init(item: LibraryItem) {
        self.item        = item
        self.currentPage = item.lastReadPage
        self.totalPages  = item.totalPages
    }

    // MARK: - Load

    func loadDocument() {
        guard let url = item.localURL else {
            setState(.error("File not found on device."))
            return
        }

        guard item.isFileExists else {
            setState(.error("This book was removed from your device."))
            return
        }

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }

            guard let document = PDFDocument(url: url) else {
                DispatchQueue.main.async {
                    self.setState(.error("Could not open this PDF."))
                }
                return
            }

            let total = document.pageCount

            DispatchQueue.main.async {
                self.totalPages = total
                LibraryManager.shared.updateProgress(
                    id: self.item.id,
                    page: self.currentPage,
                    total: total
                )
                self.setState(.ready(document))
                self.onProgressChanged?(self.currentPage, total)
            }
        }
    }

    // MARK: - Page tracking

    func updateCurrentPage(_ page: Int) {
        currentPage = page
        LibraryManager.shared.updateProgress(
            id: item.id,
            page: page,
            total: totalPages
        )
        onProgressChanged?(currentPage, totalPages)
    }

    // MARK: - Scale

    func increaseScale() { scaleFactor = min(scaleFactor + 0.25, 3.0) }
    func decreaseScale() { scaleFactor = max(scaleFactor - 0.25, 0.5) }
    func resetScale()    { scaleFactor = 1.0 }

    // MARK: - Computed

    var progressText: String { item.progressText }

    var pageDisplayText: String {
        guard totalPages > 0 else { return "" }
        return "\(currentPage + 1) / \(totalPages)"
    }

    // MARK: - Private

    private func setState(_ newState: LibraryReaderState) {
        state = newState
        onStateChanged?(newState)
    }
}
