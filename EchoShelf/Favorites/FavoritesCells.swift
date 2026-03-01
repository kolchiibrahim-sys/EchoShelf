//
//  FavoriteCells.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 01.03.26.
//
import UIKit
import Kingfisher

// MARK: - FavoriteBookCell

final class FavoriteBookCell: UICollectionViewCell {

    static let identifier = "FavoriteBookCell"

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

    private let heartButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        btn.tintColor = .systemPink
        btn.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        btn.layer.cornerRadius = 14
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
        contentView.addSubview(coverImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(authorLabel)
        contentView.addSubview(heartButton)

        NSLayoutConstraint.activate([
            coverImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            coverImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            coverImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            coverImageView.heightAnchor.constraint(equalToConstant: 160),

            heartButton.topAnchor.constraint(equalTo: coverImageView.topAnchor, constant: 8),
            heartButton.trailingAnchor.constraint(equalTo: coverImageView.trailingAnchor, constant: -8),
            heartButton.widthAnchor.constraint(equalToConstant: 28),
            heartButton.heightAnchor.constraint(equalToConstant: 28),

            titleLabel.topAnchor.constraint(equalTo: coverImageView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            authorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            authorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            authorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }

    func configure(with book: Audiobook) {
        titleLabel.text = book.title
        authorLabel.text = book.authorName
        if let url = book.coverURL {
            coverImageView.kf.setImage(with: url)
        }
    }
}

// MARK: - FavoriteAuthorCell

final class FavoriteAuthorCell: UICollectionViewCell {

    static let identifier = "FavoriteAuthorCell"

    private let avatarView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.3)
        v.layer.cornerRadius = 28
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let initialsLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 20, weight: .bold)
        lbl.textColor = .white
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let nameLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 15, weight: .semibold)
        lbl.textColor = .white
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let subLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Author"
        lbl.font = .systemFont(ofSize: 12)
        lbl.textColor = UIColor.white.withAlphaComponent(0.4)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        contentView.backgroundColor = UIColor.white.withAlphaComponent(0.04)
        contentView.layer.cornerRadius = 16

        avatarView.addSubview(initialsLabel)
        contentView.addSubview(avatarView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(subLabel)

        NSLayoutConstraint.activate([
            avatarView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            avatarView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 56),
            avatarView.heightAnchor.constraint(equalToConstant: 56),

            initialsLabel.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
            initialsLabel.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),

            nameLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 14),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 18),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),

            subLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            subLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4)
        ])
    }

    func configure(with author: Author) {
        let first = author.firstName ?? ""
        let last  = author.lastName ?? ""
        nameLabel.text = "\(first) \(last)".trimmingCharacters(in: .whitespaces)
        let fi = first.first?.uppercased() ?? ""
        let li = last.first?.uppercased() ?? ""
        initialsLabel.text = (fi + li).isEmpty ? "A" : fi + li
    }
}

// MARK: - FavoriteGenreCell

final class FavoriteGenreCell: UICollectionViewCell {

    static let identifier = "FavoriteGenreCell"

    private let gradientLayer = CAGradientLayer()

    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 15, weight: .bold)
        lbl.textColor = .white
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let genreColors: [[UIColor]] = [
        [UIColor(hex: "#6C5CE7"), UIColor(hex: "#4834D4")],
        [UIColor(hex: "#E55039"), UIColor(hex: "#E74C3C")],
        [UIColor(hex: "#00B894"), UIColor(hex: "#00897B")],
        [UIColor(hex: "#F39C12"), UIColor(hex: "#E67E22")],
        [UIColor(hex: "#A855F7"), UIColor(hex: "#7C3AED")],
        [UIColor(hex: "#3B82F6"), UIColor(hex: "#2563EB")]
    ]

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = contentView.bounds
    }

    private func setupUI() {
        contentView.layer.cornerRadius = 16
        contentView.clipsToBounds = true
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        contentView.layer.insertSublayer(gradientLayer, at: 0)
        contentView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    func configure(with genre: String) {
        titleLabel.text = genre
        let colorPair = genreColors[abs(genre.hashValue) % genreColors.count]
        gradientLayer.colors = colorPair.map { $0.cgColor }
    }
}
