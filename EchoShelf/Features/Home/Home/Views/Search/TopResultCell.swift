//
//  TopResultCell.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 24.02.26.
//
//
//  TopResultCell.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 24.02.26.
//
import UIKit
import Kingfisher

final class TopResultCell: UICollectionViewCell {

    static let identifier = "TopResultCell"

    var onListen: (() -> Void)?

    // MARK: - UI Elements
    private let container = UIView()
    private let coverImage = UIImageView()
    private let coverShadow = UIView()

    private let titleLabel = UILabel()
    private let authorLabel = UILabel()
    private let narratorLabel = UILabel()

    private let genreBadge = UILabel()
    private let chapterLabel = UILabel()
    private let starLabel = UILabel()
    private let metaStack = UIStackView()

    private let listenButton = UIButton(type: .system)
    private let downloadButton = UIButton(type: .system)

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    override func prepareForReuse() {
        super.prepareForReuse()
        coverImage.image = nil
        genreBadge.isHidden = true
        chapterLabel.text = nil
    }

    // MARK: - Setup
    private func setupUI() {

        // Container
        container.backgroundColor = UIColor.white.withAlphaComponent(0.07)
        container.layer.cornerRadius = 24
        container.layer.borderWidth = 0.5
        container.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        container.translatesAutoresizingMaskIntoConstraints = false

        // Cover shadow
        coverShadow.layer.shadowColor = UIColor.black.cgColor
        coverShadow.layer.shadowOpacity = 0.5
        coverShadow.layer.shadowRadius = 12
        coverShadow.layer.shadowOffset = CGSize(width: 0, height: 6)
        coverShadow.translatesAutoresizingMaskIntoConstraints = false

        // Cover image
        coverImage.layer.cornerRadius = 16
        coverImage.clipsToBounds = true
        coverImage.contentMode = .scaleAspectFill
        coverImage.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.2)
        coverImage.translatesAutoresizingMaskIntoConstraints = false

        // Genre badge
        genreBadge.font = .systemFont(ofSize: 10, weight: .semibold)
        genreBadge.textColor = UIColor.systemPurple
        genreBadge.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.15)
        genreBadge.layer.cornerRadius = 8
        genreBadge.clipsToBounds = true
        genreBadge.textAlignment = .center
        genreBadge.isHidden = true
        genreBadge.translatesAutoresizingMaskIntoConstraints = false

        // Title
        titleLabel.font = .systemFont(ofSize: 17, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 2

        // Author
        authorLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        authorLabel.textColor = UIColor.systemPurple

        // Narrator
        narratorLabel.font = .systemFont(ofSize: 12)
        narratorLabel.textColor = UIColor.white.withAlphaComponent(0.5)
        narratorLabel.text = "LibriVox Recording"

        // Star
        starLabel.font = .systemFont(ofSize: 12)
        starLabel.textColor = UIColor.systemYellow

        // Chapters
        chapterLabel.font = .systemFont(ofSize: 12)
        chapterLabel.textColor = UIColor.white.withAlphaComponent(0.5)

        // Meta row (star + chapters)
        metaStack.axis = .horizontal
        metaStack.spacing = 10
        metaStack.alignment = .center
        metaStack.translatesAutoresizingMaskIntoConstraints = false
        metaStack.addArrangedSubview(starLabel)
        metaStack.addArrangedSubview(chapterLabel)

        // Listen button
        listenButton.setTitle("  Listen", for: .normal)
        listenButton.tintColor = .white
        listenButton.backgroundColor = UIColor.systemPurple
        listenButton.layer.cornerRadius = 16
        listenButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        listenButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        listenButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        listenButton.addTarget(self, action: #selector(listenTapped), for: .touchUpInside)

        // Download button
        downloadButton.setImage(UIImage(systemName: "arrow.down.circle.fill"), for: .normal)
        downloadButton.tintColor = UIColor.white.withAlphaComponent(0.7)

        let buttonRow = UIStackView(arrangedSubviews: [listenButton, downloadButton])
        buttonRow.spacing = 12
        buttonRow.alignment = .center
        buttonRow.translatesAutoresizingMaskIntoConstraints = false

        // Text stack
        let textStack = UIStackView(arrangedSubviews: [
            genreBadge,
            titleLabel,
            authorLabel,
            narratorLabel,
            metaStack,
            buttonRow
        ])
        textStack.axis = .vertical
        textStack.spacing = 5
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.setCustomSpacing(8, after: narratorLabel)
        textStack.setCustomSpacing(10, after: metaStack)

        // Add to hierarchy
        contentView.addSubview(container)
        container.addSubview(coverShadow)
        coverShadow.addSubview(coverImage)
        container.addSubview(textStack)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            // Cover shadow + image
            coverShadow.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            coverShadow.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            coverShadow.widthAnchor.constraint(equalToConstant: 100),
            coverShadow.heightAnchor.constraint(equalToConstant: 130),

            coverImage.topAnchor.constraint(equalTo: coverShadow.topAnchor),
            coverImage.bottomAnchor.constraint(equalTo: coverShadow.bottomAnchor),
            coverImage.leadingAnchor.constraint(equalTo: coverShadow.leadingAnchor),
            coverImage.trailingAnchor.constraint(equalTo: coverShadow.trailingAnchor),

            // Genre badge height
            genreBadge.heightAnchor.constraint(equalToConstant: 20),

            // Text stack
            textStack.leadingAnchor.constraint(equalTo: coverShadow.trailingAnchor, constant: 14),
            textStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            textStack.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
    }

    func configure(with book: Audiobook) {
        titleLabel.text = book.title
        authorLabel.text = book.authorName
        narratorLabel.text = "LibriVox Recording"

        if let url = book.coverURL {
            coverImage.kf.setImage(with: url, placeholder: UIImage(systemName: "book.fill"))
        } else {
            coverImage.image = UIImage(systemName: "book.fill")
        }

        if let sections = book.numSections?.value {
            let word = sections == 1 ? "chapter" : "chapters"
            chapterLabel.text = "· \(sections) \(word)"
            starLabel.text = "⭐ 4.5"
            metaStack.isHidden = false
        } else {
            metaStack.isHidden = true
        }

        genreBadge.text = "  LibriVox  "
        genreBadge.isHidden = false
    }

    @objc private func listenTapped() {
        onListen?()
    }
}
