//
//  ReleatedAuthorCell.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 24.02.26.
//
import UIKit

final class RelatedAuthorCell: UICollectionViewCell {

    static let identifier = "RelatedAuthorCell"

    private let imageView = UIImageView()
    private let initialsLabel = UILabel()
    private let nameLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        initialsLabel.text = nil
    }

    private func setupUI() {

        imageView.layer.cornerRadius = 40
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.3)

        initialsLabel.textColor = .white
        initialsLabel.font = .systemFont(ofSize: 28, weight: .bold)
        initialsLabel.textAlignment = .center
        initialsLabel.translatesAutoresizingMaskIntoConstraints = false

        nameLabel.textColor = .white
        nameLabel.font = .systemFont(ofSize: 13)
        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 2
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(imageView)
        imageView.addSubview(initialsLabel)
        contentView.addSubview(nameLabel)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),

            initialsLabel.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            initialsLabel.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),

            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 6),
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    func configure(with author: Author?) {

        guard let author else {
            nameLabel.text = "Unknown Author"
            initialsLabel.text = "?"
            return
        }

        let first = author.firstName ?? ""
        let last  = author.lastName ?? ""

        nameLabel.text = "\(first) \(last)"

        let firstInitial = first.first?.uppercased() ?? ""
        let lastInitial  = last.first?.uppercased() ?? ""

        let initials = firstInitial + lastInitial
        initialsLabel.text = initials.isEmpty ? "A" : initials
    }
}
