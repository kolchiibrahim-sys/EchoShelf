//
//  RecomendedBookCell.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 24.02.26.
//
import UIKit
import Kingfisher

final class RecommendedBookCell: UICollectionViewCell {

    static let identifier = "RecommendedBookCell"

    private let containerView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        v.layer.cornerRadius = 24
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let coverImageView: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 16
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.backgroundColor = .darkGray
        return iv
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 16, weight: .semibold)
        l.textColor = .white
        l.numberOfLines = 2
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let authorLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .regular)
        l.textColor = .lightGray
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let badgeView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.2)
        v.layer.cornerRadius = 12
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let badgeLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12, weight: .bold)
        l.textColor = .systemPurple
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(coverImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(authorLabel)
        containerView.addSubview(badgeView)
        badgeView.addSubview(badgeLabel)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            coverImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            coverImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            coverImageView.widthAnchor.constraint(equalToConstant: 70),
            coverImageView.heightAnchor.constraint(equalToConstant: 90),

            titleLabel.topAnchor.constraint(equalTo: coverImageView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: coverImageView.trailingAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(equalTo: badgeView.leadingAnchor, constant: -8),

            authorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            authorLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),

            badgeView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            badgeView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            badgeView.heightAnchor.constraint(equalToConstant: 24),

            badgeLabel.leadingAnchor.constraint(equalTo: badgeView.leadingAnchor, constant: 8),
            badgeLabel.trailingAnchor.constraint(equalTo: badgeView.trailingAnchor, constant: -8),
            badgeLabel.centerYAnchor.constraint(equalTo: badgeView.centerYAnchor)
        ])
    }

    func configure(with book: Audiobook) {
        titleLabel.text = book.title
        authorLabel.text = book.authorName
        badgeLabel.text = "\(Int.random(in: 88...98))% Match"

        if let url = book.coverURL {
            coverImageView.kf.setImage(with: url)
        }
    }
}
