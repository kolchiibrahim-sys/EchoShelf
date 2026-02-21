//
//  HomeViewModel.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 21.02.26.
//
import Foundation

final class HomeViewModel {

    private let service: AudiobookServiceProtocol
    private(set) var audiobooks: [Audiobook] = []

    private var currentPage = 1
    private var isLoading = false

    var onDataUpdated: (() -> Void)?
    var onError: ((String) -> Void)?

    init(service: AudiobookServiceProtocol = AudiobookService()) {
        self.service = service
    }

    func fetchAudiobooks() {

        guard !isLoading else { return }
        isLoading = true

        service.fetchAudiobooks(page: currentPage) { [weak self] result in
            guard let self = self else { return }

            self.isLoading = false

            switch result {
            case .success(let books):
                self.audiobooks.append(contentsOf: books)
                self.currentPage += 1
                DispatchQueue.main.async {
                    self.onDataUpdated?()
                }

            case .failure(let error):
                print("ViewModel error:", error)
                DispatchQueue.main.async {
                    self.onError?("Failed to load audiobooks")
                }
            }
        }
    }

    func refresh() {
        currentPage = 1
        audiobooks.removeAll()
        fetchAudiobooks()
    }
}
