//
//  EbookCells.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 01.03.26.
//
import UIKit
import Kingfisher

// MARK: - EbookTrendingCell (TrendingBookCell ilə eyni görünüş)

final class EbookTrendingCell: UICollectionViewCell {

    static let identifier = "EbookTrendingCell"

    private let coverImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 16
        iv.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 13, weight: .semibold)
        lbl.textColor = .white
        lbl.numberOfLines = 2
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let authorLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 11)
        lbl.textColor = UIColor.white.withAlphaComponent(0.5)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let bookBadge: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.85)
        v.layer.cornerRadius = 8
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let bookBadgeLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "BOOK"
        lbl.font = .systemFont(ofSize: 9, weight: .bold)
        lbl.textColor = .white
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    override func prepareForReuse() {
        super.prepareForReuse()
        coverImageView.image = nil
    }

    private func setupUI() {
        contentView.addSubview(coverImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(authorLabel)
        bookBadge.addSubview(bookBadgeLabel)
        contentView.addSubview(bookBadge)

        NSLayoutConstraint.activate([
            coverImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            coverImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            coverImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            coverImageView.heightAnchor.constraint(equalToConstant: 190),

            bookBadge.topAnchor.constraint(equalTo: coverImageView.topAnchor, constant: 8),
            bookBadge.leadingAnchor.constraint(equalTo: coverImageView.leadingAnchor, constant: 8),
            bookBadge.heightAnchor.constraint(equalToConstant: 18),

            bookBadgeLabel.leadingAnchor.constraint(equalTo: bookBadge.leadingAnchor, constant: 6),
            bookBadgeLabel.trailingAnchor.constraint(equalTo: bookBadge.trailingAnchor, constant: -6),
            bookBadgeLabel.centerYAnchor.constraint(equalTo: bookBadge.centerYAnchor),

            titleLabel.topAnchor.constraint(equalTo: coverImageView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            authorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 3),
            authorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            authorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }

    func configure(with ebook: Ebook) {
        titleLabel.text = ebook.title
        authorLabel.text = ebook.authorName
        if let url = ebook.coverURL {
            coverImageView.kf.setImage(with: url)
        }
    }
}

// MARK: - EbookRecommendedCell (RecommendedBookCell ilə eyni görünüş)

final class EbookRecommendedCell: UICollectionViewCell {

    static let identifier = "EbookRecommendedCell"

    private let coverImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 12
        iv.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 15, weight: .semibold)
        lbl.textColor = .white
        lbl.numberOfLines = 2
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let authorLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 13)
        lbl.textColor = UIColor.white.withAlphaComponent(0.5)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let bookBadge: UILabel = {
        let lbl = UILabel()
        lbl.text = "📖 Book"
        lbl.font = .systemFont(ofSize: 11, weight: .medium)
        lbl.textColor = UIColor.systemBlue
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let readButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Read", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 12, weight: .semibold)
        btn.tintColor = .white
        btn.backgroundColor = .systemBlue
        btn.layer.cornerRadius = 14
        btn.isUserInteractionEnabled = false
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    override func prepareForReuse() {
        super.prepareForReuse()
        coverImageView.image = nil
    }

    private func setupUI() {
        contentView.backgroundColor = UIColor.white.withAlphaComponent(0.04)
        contentView.layer.cornerRadius = 16

        contentView.addSubview(coverImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(authorLabel)
        contentView.addSubview(bookBadge)
        contentView.addSubview(readButton)

        NSLayoutConstraint.activate([
            coverImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            coverImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            coverImageView.widthAnchor.constraint(equalToConstant: 72),
            coverImageView.heightAnchor.constraint(equalToConstant: 92),

            titleLabel.leadingAnchor.constraint(equalTo: coverImageView.trailingAnchor, constant: 14),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: readButton.leadingAnchor, constant: -8),

            authorLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            authorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            authorLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            bookBadge.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            bookBadge.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 6),

            readButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),
            readButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            readButton.widthAnchor.constraint(equalToConstant: 60),
            readButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }

    func configure(with ebook: Ebook) {
        titleLabel.text = ebook.title
        authorLabel.text = ebook.authorName
        if let url = ebook.coverURL {
            coverImageView.kf.setImage(with: url)
        }
    }
}
