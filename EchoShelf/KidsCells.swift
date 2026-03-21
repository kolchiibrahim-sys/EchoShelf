//
//  KidsCells.swift
//  EchoShelf
//
import UIKit
import Kingfisher

final class KidsTrendingCell: UICollectionViewCell {

    static let identifier = "KidsTrendingCell"

    private let coverImage: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 16
        iv.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.15)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let badgeLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "⭐ KIDS"
        lbl.font = .systemFont(ofSize: 9, weight: .bold)
        lbl.textColor = .black
        lbl.backgroundColor = UIColor.systemYellow
        lbl.layer.cornerRadius = 6
        lbl.clipsToBounds = true
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
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
        lbl.textColor = UIColor.systemYellow.withAlphaComponent(0.8)
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
        coverImage.image = nil
    }

    private func setupUI() {
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
            badgeLabel.widthAnchor.constraint(equalToConstant: 46),
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
final class KidsRecommendedCell: UICollectionViewCell {

    static let identifier = "KidsRecommendedCell"

    private let container: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.07)
        v.layer.cornerRadius = 18
        v.layer.borderWidth = 0.5
        v.layer.borderColor = UIColor.systemYellow.withAlphaComponent(0.2).cgColor
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let coverImage: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 12
        iv.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.15)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 13, weight: .bold)
        lbl.textColor = .white
        lbl.numberOfLines = 2
        return lbl
    }()

    private let authorLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 11, weight: .medium)
        lbl.textColor = UIColor.systemYellow.withAlphaComponent(0.8)
        return lbl
    }()

    private let emojiLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "📚"
        lbl.font = .systemFont(ofSize: 11)
        return lbl
    }()

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
        let textStack = UIStackView(arrangedSubviews: [titleLabel, authorLabel, emojiLabel])
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(container)
        container.addSubview(coverImage)
        container.addSubview(textStack)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            coverImage.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            coverImage.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            coverImage.widthAnchor.constraint(equalToConstant: 60),
            coverImage.heightAnchor.constraint(equalToConstant: 80),

            textStack.leadingAnchor.constraint(equalTo: coverImage.trailingAnchor, constant: 10),
            textStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            textStack.centerYAnchor.constraint(equalTo: coverImage.centerYAnchor)
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
