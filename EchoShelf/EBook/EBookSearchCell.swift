//
//  EbookSearchCells.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 02.03.26.
//
import UIKit
import Kingfisher

// MARK: - EbookTopResultCell

final class EbookTopResultCell: UICollectionViewCell {

    static let identifier = "EbookTopResultCell"

    var onRead: (() -> Void)?

    private let container   = UIView()
    private let coverShadow = UIView()
    private let coverImage  = UIImageView()
    private let genreBadge  = UILabel()
    private let titleLabel  = UILabel()
    private let authorLabel = UILabel()
    private let sourceLabel = UILabel()
    private let metaStack   = UIStackView()
    private let downloadLabel = UILabel()
    private let readButton  = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) { fatalError() }

    override func prepareForReuse() {
        super.prepareForReuse()
        coverImage.image = nil
    }

    private func setupUI() {
        container.backgroundColor = UIColor.white.withAlphaComponent(0.07)
        container.layer.cornerRadius = 24
        container.layer.borderWidth = 0.5
        container.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        container.translatesAutoresizingMaskIntoConstraints = false

        coverShadow.layer.shadowColor = UIColor.black.cgColor
        coverShadow.layer.shadowOpacity = 0.5
        coverShadow.layer.shadowRadius = 12
        coverShadow.layer.shadowOffset = CGSize(width: 0, height: 6)
        coverShadow.translatesAutoresizingMaskIntoConstraints = false

        coverImage.layer.cornerRadius = 16
        coverImage.clipsToBounds = true
        coverImage.contentMode = .scaleAspectFill
        coverImage.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.2)
        coverImage.translatesAutoresizingMaskIntoConstraints = false

        genreBadge.font = .systemFont(ofSize: 10, weight: .semibold)
        genreBadge.textColor = UIColor.systemBlue
        genreBadge.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.15)
        genreBadge.layer.cornerRadius = 8
        genreBadge.clipsToBounds = true
        genreBadge.textAlignment = .center
        genreBadge.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.font = .systemFont(ofSize: 17, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 2

        authorLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        authorLabel.textColor = UIColor.systemBlue

        sourceLabel.font = .systemFont(ofSize: 12)
        sourceLabel.textColor = UIColor.white.withAlphaComponent(0.5)
        sourceLabel.text = "Project Gutenberg"

        downloadLabel.font = .systemFont(ofSize: 12)
        downloadLabel.textColor = UIColor.white.withAlphaComponent(0.5)

        metaStack.axis = .horizontal
        metaStack.spacing = 10
        metaStack.alignment = .center
        metaStack.translatesAutoresizingMaskIntoConstraints = false
        metaStack.addArrangedSubview(downloadLabel)

        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .systemBlue
        config.baseForegroundColor = .white
        config.cornerStyle = .capsule
        config.image = UIImage(systemName: "book.fill")
        config.imagePlacement = .leading
        config.imagePadding = 6
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
        var titleAttr = AttributedString("Read")
        titleAttr.font = .systemFont(ofSize: 14, weight: .semibold)
        config.attributedTitle = titleAttr
        readButton.configuration = config
        readButton.addTarget(self, action: #selector(readTapped), for: .touchUpInside)

        let buttonRow = UIStackView(arrangedSubviews: [readButton])
        buttonRow.translatesAutoresizingMaskIntoConstraints = false

        let textStack = UIStackView(arrangedSubviews: [
            genreBadge, titleLabel, authorLabel, sourceLabel, metaStack, buttonRow
        ])
        textStack.axis = .vertical
        textStack.spacing = 5
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.setCustomSpacing(8, after: sourceLabel)
        textStack.setCustomSpacing(10, after: metaStack)

        contentView.addSubview(container)
        container.addSubview(coverShadow)
        coverShadow.addSubview(coverImage)
        container.addSubview(textStack)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            coverShadow.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            coverShadow.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            coverShadow.widthAnchor.constraint(equalToConstant: 100),
            coverShadow.heightAnchor.constraint(equalToConstant: 130),

            coverImage.topAnchor.constraint(equalTo: coverShadow.topAnchor),
            coverImage.bottomAnchor.constraint(equalTo: coverShadow.bottomAnchor),
            coverImage.leadingAnchor.constraint(equalTo: coverShadow.leadingAnchor),
            coverImage.trailingAnchor.constraint(equalTo: coverShadow.trailingAnchor),

            genreBadge.heightAnchor.constraint(equalToConstant: 20),

            textStack.leadingAnchor.constraint(equalTo: coverShadow.trailingAnchor, constant: 14),
            textStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            textStack.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
    }

    func configure(with ebook: Ebook) {
        titleLabel.text = ebook.title
        authorLabel.text = ebook.authorName
        if let url = ebook.coverURL {
            coverImage.kf.setImage(with: url, placeholder: UIImage(systemName: "book.fill"))
        }
        if ebook.downloadCount > 0 {
            downloadLabel.text = "📥 \(ebook.downloadCount) downloads"
        }
        genreBadge.text = "  Gutenberg  "
    }

    @objc private func readTapped() { onRead?() }
}

// MARK: - EbookOtherResultCell

final class EbookOtherResultCell: UICollectionViewCell {

    static let identifier = "EbookOtherResultCell"

    private let container    = UIView()
    private let coverImage   = UIImageView()
    private let titleLabel   = UILabel()
    private let authorLabel  = UILabel()
    private let downloadLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) { fatalError() }

    override func prepareForReuse() {
        super.prepareForReuse()
        coverImage.image = nil
    }

    private func setupUI() {
        container.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        container.layer.cornerRadius = 16
        container.translatesAutoresizingMaskIntoConstraints = false

        coverImage.layer.cornerRadius = 10
        coverImage.clipsToBounds = true
        coverImage.contentMode = .scaleAspectFill
        coverImage.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.15)
        coverImage.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.font = .systemFont(ofSize: 15, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 2

        authorLabel.font = .systemFont(ofSize: 13, weight: .medium)
        authorLabel.textColor = UIColor.systemBlue

        downloadLabel.font = .systemFont(ofSize: 12)
        downloadLabel.textColor = UIColor.white.withAlphaComponent(0.5)
        downloadLabel.textAlignment = .right

        let leftStack = UIStackView(arrangedSubviews: [titleLabel, authorLabel, downloadLabel])
        leftStack.axis = .vertical
        leftStack.spacing = 4

        let mainStack = UIStackView(arrangedSubviews: [leftStack])
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(container)
        container.addSubview(coverImage)
        container.addSubview(mainStack)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            coverImage.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 14),
            coverImage.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            coverImage.widthAnchor.constraint(equalToConstant: 55),
            coverImage.heightAnchor.constraint(equalToConstant: 75),

            mainStack.leadingAnchor.constraint(equalTo: coverImage.trailingAnchor, constant: 12),
            mainStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -14),
            mainStack.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
    }

    func configure(with ebook: Ebook) {
        titleLabel.text  = ebook.title
        authorLabel.text = ebook.authorName
        if ebook.downloadCount > 0 {
            downloadLabel.text = "\(ebook.downloadCount)↓"
        }
        if let url = ebook.coverURL {
            coverImage.kf.setImage(with: url)
        }
    }
}

// MARK: - EbookYouMightLikeCell (TrendingBookCell ilə eyni layout, mavi tema)

final class EbookYouMightLikeCell: UICollectionViewCell {

    static let identifier = "EbookYouMightLikeCell"

    private let coverImage  = UIImageView()
    private let titleLabel  = UILabel()
    private let authorLabel = UILabel()
    private let badgeLabel  = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) { fatalError() }

    override func prepareForReuse() {
        super.prepareForReuse()
        coverImage.image = nil
    }

    private func setupUI() {
        coverImage.layer.cornerRadius = 14
        coverImage.clipsToBounds = true
        coverImage.contentMode = .scaleAspectFill
        coverImage.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.15)
        coverImage.translatesAutoresizingMaskIntoConstraints = false

        badgeLabel.text = "BOOK"
        badgeLabel.font = .systemFont(ofSize: 9, weight: .bold)
        badgeLabel.textColor = .white
        badgeLabel.backgroundColor = UIColor.systemBlue
        badgeLabel.layer.cornerRadius = 6
        badgeLabel.clipsToBounds = true
        badgeLabel.textAlignment = .center
        badgeLabel.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        authorLabel.font = .systemFont(ofSize: 11)
        authorLabel.textColor = UIColor.systemBlue
        authorLabel.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(coverImage)
        contentView.addSubview(badgeLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(authorLabel)

        NSLayoutConstraint.activate([
            coverImage.topAnchor.constraint(equalTo: contentView.topAnchor),
            coverImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            coverImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            coverImage.heightAnchor.constraint(equalToConstant: 170),

            badgeLabel.topAnchor.constraint(equalTo: coverImage.topAnchor, constant: 8),
            badgeLabel.trailingAnchor.constraint(equalTo: coverImage.trailingAnchor, constant: -8),
            badgeLabel.widthAnchor.constraint(equalToConstant: 36),
            badgeLabel.heightAnchor.constraint(equalToConstant: 18),

            titleLabel.topAnchor.constraint(equalTo: coverImage.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            authorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 3),
            authorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            authorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }

    func configure(with ebook: Ebook) {
        titleLabel.text  = ebook.title
        authorLabel.text = ebook.authorName
        if let url = ebook.coverURL {
            coverImage.kf.setImage(with: url)
        }
    }
}
