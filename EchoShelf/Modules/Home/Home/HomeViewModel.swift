//
//  HomeViewModel.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 21.02.26.
//
import Foundation

final class HomeViewModel {

    private let service: AudiobookServiceProtocol
    private(set) var books: [Audiobook] = []

    var onDataUpdated: (() -> Void)?
    var onError: ((String) -> Void)?

    init(service: AudiobookServiceProtocol = AudiobookService()) {
        self.service = service
    }

    func fetchBooks() {

        service.fetchAudiobooks(page: 1) { [weak self] result in
            guard let self else { return }

            switch result {

            case .success(let books):
                DispatchQueue.main.async {
                    self.books = books
                    self.onDataUpdated?()
                }

            case .failure:
                DispatchQueue.main.async {
                    self.onError?("Failed to load books")
                }
            }
        }
    }
}
