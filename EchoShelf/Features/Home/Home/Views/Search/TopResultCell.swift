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

    private let container = UIView()
    private let coverImage = UIImageView()
    private let titleLabel = UILabel()
    private let authorLabel = UILabel()
    private let narratorLabel = UILabel()
    private let listenButton = UIButton(type: .system)
    private let downloadButton = UIButton(type: .system)

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
        container.layer.cornerRadius = 22
        container.translatesAutoresizingMaskIntoConstraints = false

        coverImage.layer.cornerRadius = 14
        coverImage.clipsToBounds = true
        coverImage.translatesAutoresizingMaskIntoConstraints = false
        coverImage.contentMode = .scaleAspectFill

        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 2

        authorLabel.font = .systemFont(ofSize: 14, weight: .medium)
        authorLabel.textColor = UIColor.systemPurple

        narratorLabel.font = .systemFont(ofSize: 13)
        narratorLabel.textColor = UIColor.white.withAlphaComponent(0.6)
        narratorLabel.text = "LibriVox Recording"

        listenButton.setTitle(" Listen", for: .normal)
        listenButton.tintColor = .white
        listenButton.backgroundColor = UIColor.systemPurple
        listenButton.layer.cornerRadius = 16
        listenButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        listenButton.setImage(UIImage(systemName: "play.fill"), for: .normal)

        downloadButton.setImage(UIImage(systemName: "arrow.down.circle.fill"), for: .normal)
        downloadButton.tintColor = UIColor.white.withAlphaComponent(0.8)

        let buttonStack = UIStackView(arrangedSubviews: [listenButton, downloadButton])
        buttonStack.spacing = 12
        buttonStack.alignment = .center
        buttonStack.translatesAutoresizingMaskIntoConstraints = false

        let textStack = UIStackView(arrangedSubviews: [titleLabel, authorLabel, narratorLabel, buttonStack])
        textStack.axis = .vertical
        textStack.spacing = 6
        textStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(container)
        container.addSubview(coverImage)
        container.addSubview(textStack)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            coverImage.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            coverImage.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            coverImage.widthAnchor.constraint(equalToConstant: 80),
            coverImage.heightAnchor.constraint(equalToConstant: 110),

            textStack.leadingAnchor.constraint(equalTo: coverImage.trailingAnchor, constant: 14),
            textStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            textStack.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
    }

    func configure(with book: Audiobook) {
        titleLabel.text = book.title
        authorLabel.text = book.authors?.first?.firstName ?? "Unknown Author"

        if let url = book.coverURL {
            coverImage.kf.setImage(with: url)
        }
        }
    }

