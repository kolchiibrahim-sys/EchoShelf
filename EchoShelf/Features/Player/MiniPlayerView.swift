//
//  MiniPlayerView.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 24.02.26.
//
import UIKit
import Kingfisher

final class MiniPlayerView: UIView {

    private lazy var coverImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 8
        iv.backgroundColor = UIColor(named: "FillGlass")
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private lazy var titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = UIColor(named: "OnDarkTextPrimary")
        lbl.font = .systemFont(ofSize: 14, weight: .semibold)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private lazy var authorLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = UIColor(named: "OnDarkTextSecondary")
        lbl.font = .systemFont(ofSize: 12)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private lazy var playPauseButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        btn.tintColor = UIColor(named: "OnDarkTextPrimary")
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private lazy var progressView: UIProgressView = {
        let pv = UIProgressView(progressViewStyle: .bar)
        pv.progressTintColor = UIColor(named: "PrimaryGradientStart")
        pv.trackTintColor = UIColor(named: "FillGlass")
        pv.translatesAutoresizingMaskIntoConstraints = false
        return pv
    }()

    private lazy var divider: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(named: "Divider")
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupActions()
        setupTapGesture()
        observeProgress()
        updateWithCurrentBook()
    }

    required init?(coder: NSCoder) { fatalError() }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupUI() {
        backgroundColor = .clear

        addSubview(divider)
        addSubview(coverImageView)
        addSubview(titleLabel)
        addSubview(authorLabel)
        addSubview(playPauseButton)
        addSubview(progressView)

        NSLayoutConstraint.activate([
            divider.topAnchor.constraint(equalTo: topAnchor),
            divider.leadingAnchor.constraint(equalTo: leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: trailingAnchor),
            divider.heightAnchor.constraint(equalToConstant: 0.5),

            coverImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            coverImageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -4),
            coverImageView.widthAnchor.constraint(equalToConstant: 44),
            coverImageView.heightAnchor.constraint(equalToConstant: 44),

            titleLabel.leadingAnchor.constraint(equalTo: coverImageView.trailingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: playPauseButton.leadingAnchor, constant: -8),
            titleLabel.topAnchor.constraint(equalTo: coverImageView.topAnchor, constant: 2),

            authorLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            authorLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            authorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 3),

            playPauseButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            playPauseButton.centerYAnchor.constraint(equalTo: coverImageView.centerYAnchor),
            playPauseButton.widthAnchor.constraint(equalToConstant: 36),
            playPauseButton.heightAnchor.constraint(equalToConstant: 36),

            progressView.leadingAnchor.constraint(equalTo: leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: trailingAnchor),
            progressView.bottomAnchor.constraint(equalTo: bottomAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 2)
        ])
    }

    private func setupActions() {
        playPauseButton.addTarget(self, action: #selector(playPauseTapped), for: .touchUpInside)
    }

    private func setupTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(openPlayer))
        addGestureRecognizer(tap)
    }

    private func observeProgress() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(progressUpdated),
            name: .playerProgressUpdated,
            object: nil
        )
    }

    private func updateWithCurrentBook() {
        guard let book = PlayerManager.shared.currentBook else { return }
        titleLabel.text = book.title
        authorLabel.text = book.authorName
        let url = book.coverURL ?? book.archiveCoverURL
        coverImageView.kf.setImage(with: url)
        updatePlayPauseButton()
    }

    private func updatePlayPauseButton() {
        let icon = PlayerManager.shared.isPlaying ? "pause.fill" : "play.fill"
        playPauseButton.setImage(UIImage(systemName: icon), for: .normal)
    }

    @objc private func progressUpdated() {
        updateWithCurrentBook()
        let progress = PlayerManager.shared.duration > 0
            ? Float(PlayerManager.shared.currentTime / PlayerManager.shared.duration)
            : 0
        progressView.setProgress(progress, animated: true)
        updatePlayPauseButton()
    }

    @objc private func playPauseTapped() {
        PlayerManager.shared.togglePlayPause()
        updatePlayPauseButton()
    }

    @objc private func openPlayer() {
        NotificationCenter.default.post(name: .openFullPlayer, object: nil)
    }
}
