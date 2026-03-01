//
//  EbookReaderViewModel.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 01.03.26.
//
import Foundation
import PDFKit

enum EbookReaderState {
    case idle
    case loading
    case loadedPDF(PDFDocument)
    case loadedWeb(URL)     // WKWebView ilə app içində aç
    case error(String)
}

final class EbookReaderViewModel {

    // MARK: - Properties

    let ebook: Ebook
    private(set) var readURL: URL
    private(set) var state: EbookReaderState = .idle

    private(set) var currentPage: Int = 0
    private(set) var totalPages: Int = 0
    private(set) var scaleFactor: CGFloat = 1.0

    // MARK: - Callbacks

    var onStateChanged: ((EbookReaderState) -> Void)?
    var onProgressChanged: ((Int, Int) -> Void)?  // current, total

    // MARK: - Init

    init(ebook: Ebook, readURL: URL) {
        self.ebook = ebook
        self.readURL = readURL
    }

    // MARK: - Load

    func loadDocument() {
        guard state.isIdle else { return }
        setState(.loading)

        let isPDF = readURL.pathExtension.lowercased() == "pdf"
        if isPDF {
            loadPDF(from: readURL)
        } else {
            setState(.loadedWeb(readURL))
        }
    }

    func fetchAndLoad(workKey: String) {
        guard state.isIdle else { return }
        setState(.loading)

        EbookService.shared.fetchReadLinks(workKey: workKey) { [weak self] url in
            guard let self else { return }
            DispatchQueue.main.async {
                if let url {
                    self.readURL = url
                    let isPDF = url.pathExtension.lowercased() == "pdf"
                    if isPDF {
                        self.loadPDF(from: url)
                    } else {
                        self.setState(.loadedWeb(url))
                    }
                } else {
                    // Fallback — Open Library web reader
                    let fallback = URL(string: "https://openlibrary.org\(workKey)")!
                    self.setState(.loadedWeb(fallback))
                }
            }
        }
    }

    // MARK: - Page Navigation

    func updateCurrentPage(_ page: Int) {
        currentPage = page
        onProgressChanged?(currentPage, totalPages)
    }

    // MARK: - Scale

    func increaseScale() {
        scaleFactor = min(scaleFactor + 0.25, 3.0)
    }

    func decreaseScale() {
        scaleFactor = max(scaleFactor - 0.25, 0.5)
    }

    func resetScale() {
        scaleFactor = 1.0
    }

    // MARK: - Private

    private func loadPDF(from url: URL) {
        // PDFDocument(url:) yalnız local fayllar üçün işləyir
        // Remote URL-lər üçün əvvəlcə data yükləmək lazımdır
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self else { return }

            if let error {
                DispatchQueue.main.async {
                    self.setState(.error("Download failed: \(error.localizedDescription)"))
                }
                return
            }

            guard let data, let document = PDFDocument(data: data) else {
                DispatchQueue.main.async {
                    self.setState(.error("Could not open this document."))
                }
                return
            }

            self.totalPages = document.pageCount
            DispatchQueue.main.async {
                self.setState(.loadedPDF(document))
                self.onProgressChanged?(0, document.pageCount)
            }
        }.resume()
    }

    private func setState(_ newState: EbookReaderState) {
        state = newState
        onStateChanged?(newState)
    }
}

// MARK: - State Helpers

private extension EbookReaderState {
    var isIdle: Bool {
        if case .idle = self { return true }
        return false
    }
}
