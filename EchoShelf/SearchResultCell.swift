//
//  SearchResultCell.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 24.02.26.
//
import UIKit
import Kingfisher

final class SearchResultCell: UICollectionViewCell {

    static let identifier = "SearchResultCell"

    private let container = UIView()
    private let coverImage = UIImageView()
    private let titleLabel = UILabel()
    private let authorLabel = UILabel()
    private let narratorLabel = UILabel()
    private let durationLabel = UILabel()

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
        container.layer.cornerRadius = 18
        container.translatesAutoresizingMaskIntoConstraints = false

        coverImage.layer.cornerRadius = 10
        coverImage.clipsToBounds = true
        coverImage.translatesAutoresizingMaskIntoConstraints = false
        coverImage.contentMode = .scaleAspectFill

        titleLabel.font = .systemFont(ofSize: 15, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 2

        authorLabel.font = .systemFont(ofSize: 13, weight: .medium)
        authorLabel.textColor = UIColor.systemPurple

        narratorLabel.font = .systemFont(ofSize: 12)
        narratorLabel.textColor = UIColor.white.withAlphaComponent(0.6)

        durationLabel.font = .systemFont(ofSize: 12)
        durationLabel.textColor = UIColor.white.withAlphaComponent(0.6)
        durationLabel.textAlignment = .right

        let leftStack = UIStackView(arrangedSubviews: [titleLabel, authorLabel, narratorLabel])
        leftStack.axis = .vertical
        leftStack.spacing = 4

        let mainStack = UIStackView(arrangedSubviews: [leftStack, durationLabel])
        mainStack.spacing = 8
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

    func configure(with book: Audiobook) {

        titleLabel.text = book.title
        authorLabel.text = book.authorName
        narratorLabel.text = "LibriVox"

        if let sections = book.numSections?.value {
            durationLabel.text = "\(sections) chapters"
        } else {
            durationLabel.text = nil
        }

        if let url = book.coverURL {
            coverImage.kf.setImage(with: url)
        } else {
            coverImage.image = UIImage(systemName: "book.fill")
        }
    }
}
