//
//  EbookReaderViewModel.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 02.03.26.
//
import Foundation
import PDFKit

enum EbookReaderState {
    case idle
    case downloading(Float)
    case loaded(PDFDocument)
    case error(String)
}
final class EbookReaderViewModel {

    let ebook: Ebook

    private(set) var state: EbookReaderState = .idle
    private(set) var currentPage: Int = 0
    private(set) var totalPages: Int = 0
    private(set) var scaleFactor: CGFloat = 1.0

    private var downloadTask: URLSessionDataTask?

    var onStateChanged: ((EbookReaderState) -> Void)?
    var onProgressChanged: ((Int, Int) -> Void)?

    init(ebook: Ebook) {
        self.ebook = ebook
    }

    func loadDocument() {
        guard case .idle = state else { return }

        guard let rawURL = ebook.pdfURL else {
            setState(.error("No PDF available for this book."))
            return
        }

        let urlStr = rawURL.absoluteString.replacingOccurrences(of: "http://", with: "https://")
        guard let pdfURL = URL(string: urlStr) else {
            setState(.error("Invalid PDF URL."))
            return
        }

        setState(.downloading(0))
        downloadPDF(from: pdfURL)
    }

    func cancelDownload() {
        downloadTask?.cancel()
        setState(.idle)
    }

    func updateCurrentPage(_ page: Int) {
        currentPage = page
        LibraryManager.shared.updateProgress(
            id: ebook.id,
            page: page,
            total: totalPages
        )
        onProgressChanged?(currentPage, totalPages)
    }

    func increaseScale() { scaleFactor = min(scaleFactor + 0.25, 3.0) }
    func decreaseScale() { scaleFactor = max(scaleFactor - 0.25, 0.5) }
    func resetScale()    { scaleFactor = 1.0 }

    private func downloadPDF(from url: URL) {
        var request = URLRequest(url: url)
        request.timeoutInterval = 60

        let session = URLSession(
            configuration: .default,
            delegate: DownloadDelegate { [weak self] progress in
                DispatchQueue.main.async {
                    self?.setState(.downloading(progress))
                }
            },
            delegateQueue: nil
        )

        downloadTask = session.dataTask(with: request) { [weak self] data, _, error in
            guard let self else { return }

            DispatchQueue.main.async {
                if let error = error as NSError?, error.code == NSURLErrorCancelled {
                    return
                }

                guard let data, error == nil else {
                    self.setState(.error("Download failed. Please check your connection."))
                    return
                }

                guard let document = PDFDocument(data: data) else {
                    self.setState(.error("Could not open this PDF."))
                    return
                }

                self.totalPages = document.pageCount

                try? LibraryManager.shared.saveBook(from: self.ebook, pdfData: data)

                self.setState(.loaded(document))
                self.onProgressChanged?(0, document.pageCount)
            }
        }
        downloadTask?.resume()
    }

    private func setState(_ newState: EbookReaderState) {
        state = newState
        onStateChanged?(newState)
    }
}

private final class DownloadDelegate: NSObject, URLSessionDataDelegate {

    private var expectedBytes: Int64 = 0
    private var receivedBytes: Int64 = 0
    private let onProgress: (Float) -> Void

    init(onProgress: @escaping (Float) -> Void) {
        self.onProgress = onProgress
    }

    func urlSession(_ session: URLSession,
                    dataTask: URLSessionDataTask,
                    didReceive response: URLResponse,
                    completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        expectedBytes = response.expectedContentLength
        completionHandler(.allow)
    }

    func urlSession(_ session: URLSession,
                    dataTask: URLSessionDataTask,
                    didReceive data: Data) {
        receivedBytes += Int64(data.count)
        guard expectedBytes > 0 else { return }
        let progress = Float(receivedBytes) / Float(expectedBytes)
        onProgress(min(progress, 1.0))
    }
}
