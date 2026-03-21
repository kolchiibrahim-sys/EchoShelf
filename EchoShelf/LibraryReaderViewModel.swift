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

    let item: LibraryItem

    private(set) var state: LibraryReaderState = .loading
    private(set) var currentPage: Int
    private(set) var totalPages:  Int
    private(set) var scaleFactor: CGFloat = 1.0
    var onStateChanged:    ((LibraryReaderState) -> Void)?
    var onProgressChanged: ((Int, Int) -> Void)?
    init(item: LibraryItem) {
        self.item        = item
        self.currentPage = item.lastReadPage
        self.totalPages  = item.totalPages
    }

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
    func updateCurrentPage(_ page: Int) {
        currentPage = page
        LibraryManager.shared.updateProgress(
            id: item.id,
            page: page,
            total: totalPages
        )
        onProgressChanged?(currentPage, totalPages)
    }

    func increaseScale() { scaleFactor = min(scaleFactor + 0.25, 3.0) }
    func decreaseScale() { scaleFactor = max(scaleFactor - 0.25, 0.5) }
    func resetScale()    { scaleFactor = 1.0 }

    var progressText: String { item.progressText }

    var pageDisplayText: String {
        guard totalPages > 0 else { return "" }
        return "\(currentPage + 1) / \(totalPages)"
    }


    private func setState(_ newState: LibraryReaderState) {
        state = newState
        onStateChanged?(newState)
    }
}
