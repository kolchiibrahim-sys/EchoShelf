//
//  BookDetailViewModel.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 27.02.26.
//
import Foundation

final class BookDetailViewModel {

    private let service: AudiobookServiceProtocol
    private(set) var book: Audiobook

    var onDataUpdated: (() -> Void)?
    var onError: ((String) -> Void)?

    init(book: Audiobook,
         service: AudiobookServiceProtocol = AudiobookService()) {
        self.book = book
        self.service = service
    }

    func fetchDetail() {

        service.fetchAudiobookDetail(id: book.id.value) { [weak self] result in
            guard let self else { return }

            DispatchQueue.main.async {
                switch result {

                case .success(let updatedBook):
                    self.book = updatedBook
                    self.onDataUpdated?()

                case .failure:
                    self.onError?("Failed to load book detail")
                }
            }
        }
    }
}
