//
//  PlayerManager.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 24.02.26.
//
import Foundation

final class PlayerManager {

    static let shared = PlayerManager()

    private init() {}

    private(set) var currentBook: Audiobook?

    var onPlayerStarted: ((Audiobook) -> Void)?
    var onPlayerStopped: (() -> Void)?

    func play(book: Audiobook) {
        currentBook = book
        onPlayerStarted?(book)
    }

    func stop() {
        currentBook = nil
        onPlayerStopped?()
    }
}
