//
//  BookDetailViewController.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 22.02.26.
//
import UIKit
import Kingfisher

final class BookDetailViewController: UIViewController {

    private let book: Audiobook

    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let authorLabel = UILabel()
    private let descriptionLabel = UILabel()

    init(book: Audiobook) {
        self.book = book
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Book Details"
        setupUI()
        configure()
    }

    private func setupUI() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12

        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        titleLabel.numberOfLines = 0

        authorLabel.font = .systemFont(ofSize: 16)
        authorLabel.textColor = .secondaryLabel

        descriptionLabel.font = .systemFont(ofSize: 15)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textColor = .secondaryLabel

        let stack = UIStackView(arrangedSubviews: [
            imageView,
            titleLabel,
            authorLabel,
            descriptionLabel
        ])

        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)

        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 220),

            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    private func configure() {
        titleLabel.text = book.title
        authorLabel.text = book.authorName
        descriptionLabel.text = "LibriVox audiobook"

        if let url = URL(string: book.coverURL ?? "") {
            imageView.kf.setImage(with: url)
        }
    }
}
