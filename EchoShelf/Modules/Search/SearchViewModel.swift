//
//  SearchViewModel.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 22.02.26.
//
import Foundation

final class SearchViewModel {

    private let service: AudiobookServiceProtocol
    private(set) var books: [Audiobook] = []

    var onDataUpdated: (() -> Void)?
    var onError: ((String) -> Void)?

    init(service: AudiobookServiceProtocol = AudiobookService()) {
        self.service = service
    }

    func search(query: String) {

        guard !query.isEmpty else { return }

        service.searchAudiobooks(query: query) { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let books):
                self.books = books
                DispatchQueue.main.async {
                    self.onDataUpdated?()
                }

            case .failure:
                DispatchQueue.main.async {
                    self.onError?("Search failed")
                }
            }
        }
    }
}
