//
//  ContinueListeningCard.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 24.02.26.
//
import UIKit

final class ContinueListeningCard: UIView {

    private let cardView = UIView()
    private let coverImage = UIImageView()
    private let titleLabel = UILabel()
    private let authorLabel = UILabel()
    private let progressView = UIProgressView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup() {

        cardView.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        cardView.layer.cornerRadius = 24
        cardView.translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 140).isActive = true
        addSubview(cardView)

        NSLayoutConstraint.activate([
            cardView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            cardView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            cardView.topAnchor.constraint(equalTo: topAnchor),
            cardView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        coverImage.image = UIImage(systemName: "book.fill")
        coverImage.tintColor = .white
        coverImage.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.text = "The Midnight Library"
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)

        authorLabel.text = "Matt Haig"
        authorLabel.textColor = UIColor.white.withAlphaComponent(0.7)

        progressView.progress = 0.65
        progressView.tintColor = .systemPurple

        let textStack = UIStackView(arrangedSubviews: [titleLabel, authorLabel, progressView])
        textStack.axis = .vertical
        textStack.spacing = 8
        textStack.translatesAutoresizingMaskIntoConstraints = false

        cardView.addSubview(coverImage)
        cardView.addSubview(textStack)

        NSLayoutConstraint.activate([
            coverImage.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            coverImage.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            coverImage.widthAnchor.constraint(equalToConstant: 60),
            coverImage.heightAnchor.constraint(equalToConstant: 80),

            textStack.leadingAnchor.constraint(equalTo: coverImage.trailingAnchor, constant: 16),
            textStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            textStack.centerYAnchor.constraint(equalTo: coverImage.centerYAnchor),
            textStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -20)
        ])
    }
}
