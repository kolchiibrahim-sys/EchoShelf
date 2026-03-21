//
//  MiniPlayerView.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 24.02.26.
import UIKit

final class MiniPlayerView: UIView {

    private let titleLabel = UILabel()
    private let playPauseButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupTapGesture()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {

        backgroundColor = UIColor(named: "AppBackground")

        titleLabel.text = "Now Playing"
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)

        playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        playPauseButton.tintColor = .white

        addSubview(titleLabel)
        addSubview(playPauseButton)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        playPauseButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            playPauseButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            playPauseButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    private func setupTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(openPlayer))
        addGestureRecognizer(tap)
    }

    @objc private func openPlayer() {
        NotificationCenter.default.post(name: .openFullPlayer, object: nil)
    }
}
