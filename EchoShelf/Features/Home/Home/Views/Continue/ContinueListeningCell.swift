//
//  ContinueListeningCell.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 24.02.26.
//
import UIKit
import Kingfisher

final class ContinueListeningCell: UICollectionViewCell {

    static let identifier = "ContinueListeningCell"

    private let coverImage = UIImageView()
    private let titleLabel = UILabel()
    private let authorLabel = UILabel()
    private let progressView = UIProgressView(progressViewStyle: .default)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupObservers()
    }

    required init?(coder: NSCoder) { fatalError() }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupUI() {

        backgroundColor = UIColor.white.withAlphaComponent(0.05)
        layer.cornerRadius = 20

        coverImage.layer.cornerRadius = 12
        coverImage.clipsToBounds = true
        coverImage.contentMode = .scaleAspectFill
        coverImage.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 2

        authorLabel.font = .systemFont(ofSize: 14)
        authorLabel.textColor = UIColor.white.withAlphaComponent(0.7)

        progressView.progressTintColor = .systemPurple
        progressView.trackTintColor = UIColor.white.withAlphaComponent(0.2)

        let stack = UIStackView(arrangedSubviews: [titleLabel, authorLabel, progressView])
        stack.axis = .vertical
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(coverImage)
        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            coverImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            coverImage.centerYAnchor.constraint(equalTo: centerYAnchor),
            coverImage.widthAnchor.constraint(equalToConstant: 60),
            coverImage.heightAnchor.constraint(equalToConstant: 80),

            stack.leadingAnchor.constraint(equalTo: coverImage.trailingAnchor, constant: 14),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    private func setupObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateProgress),
            name: .playerProgressUpdated,
            object: nil
        )
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        coverImage.image = nil
        progressView.progress = 0
    }

    func configure() {

        guard let book = PlayerManager.shared.currentBook else {
            isHidden = true
            return
        }

        isHidden = false
        titleLabel.text = book.title
        authorLabel.text = book.authorName

        if let url = book.coverURL {
            coverImage.kf.setImage(with: url)
        } else {
            coverImage.image = UIImage(systemName: "book.fill")
        }

        updateProgress()
    }

    @objc private func updateProgress() {

        let current = PlayerManager.shared.currentTime
        let duration = PlayerManager.shared.duration

        guard duration > 0 else { return }

        let progress = Float(current / duration)
        progressView.setProgress(progress, animated: true)
    }
}
