//
//  AudioPlayerManager.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 24.02.26.
//
import AVFoundation

final class AudioPlayerManager {

    static let shared = AudioPlayerManager()

    private var player: AVPlayer?

    private(set) var currentBook: Audiobook?

    var onStateChanged: (() -> Void)?

    private init() {}

    func play(book: Audiobook) {
        currentBook = book
        
        guard let url = URL(string: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3") else { return }

        player = AVPlayer(url: url)
        player?.play()
        
        onStateChanged?()
    }

    func pause() {
        player?.pause()
    }

    func resume() {
        player?.play()
    }
}
