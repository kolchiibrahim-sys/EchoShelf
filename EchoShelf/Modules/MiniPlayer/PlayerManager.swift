//
//  PlayerManager.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 24.02.26.
//
import Foundation
import AVFoundation



final class PlayerManager {

    static let shared = PlayerManager()
    private init() {}

    private var player: AVPlayer?
    private var timeObserver: Any?

    private(set) var currentBook: Audiobook?
    private(set) var currentTime: Double = 0
    private(set) var duration: Double = 1

    var isPlaying: Bool {
        player?.timeControlStatus == .playing
    }

    func play(book: Audiobook, previewURL: URL? = nil) {

        currentBook = book

        removeTimeObserver()

        guard let url = previewURL else {
            NotificationCenter.default.post(name: .playerStarted, object: nil)
            return
        }

        let item = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: item)
        player?.play()

        addTimeObserver()

        NotificationCenter.default.post(name: .playerStarted, object: nil)
    }

    func pause() {
        player?.pause()
    }

    func resume() {
        player?.play()
    }

    func togglePlayPause() {
        isPlaying ? pause() : resume()
    }

    private func addTimeObserver() {

        guard let player else { return }

        let interval = CMTime(seconds: 1, preferredTimescale: 1)

        timeObserver = player.addPeriodicTimeObserver(
            forInterval: interval,
            queue: .main
        ) { [weak self] time in

            guard let self else { return }

            self.currentTime = time.seconds

            if let duration = player.currentItem?.duration.seconds,
               duration.isFinite {
                self.duration = duration
            }

            NotificationCenter.default.post(name: .playerProgressUpdated, object: nil)
        }
    }

    private func removeTimeObserver() {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
    }
}
