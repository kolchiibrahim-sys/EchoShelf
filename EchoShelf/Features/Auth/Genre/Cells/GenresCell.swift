//
//  GenresCell.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 24.02.26.
//
import UIKit

final class GenreCell: UICollectionViewCell {

    static let identifier = "GenreCell"

    var onFavoriteTapped: (() -> Void)?

    private lazy var iconLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 28)
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private lazy var titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 14, weight: .bold)
        lbl.textColor = .white
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private lazy var descriptionLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 11)
        lbl.textColor = UIColor.white.withAlphaComponent(0.7)
        lbl.numberOfLines = 2
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private lazy var favoriteButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "heart"), for: .normal)
        btn.tintColor = UIColor.white.withAlphaComponent(0.8)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        contentView.layer.cornerRadius = 16
        contentView.clipsToBounds = true
        contentView.backgroundColor = UIColor.white.withAlphaComponent(0.08)

        contentView.addSubview(iconLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(favoriteButton)

        NSLayoutConstraint.activate([
            iconLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            iconLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),

            favoriteButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            favoriteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            favoriteButton.widthAnchor.constraint(equalToConstant: 28),
            favoriteButton.heightAnchor.constraint(equalToConstant: 28),

            titleLabel.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),

            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -12)
        ])

        favoriteButton.addTarget(self, action: #selector(favTapped), for: .touchUpInside)
    }

    func configure(with genre: Genre, isFavorited: Bool) {
        iconLabel.text = genre.icon
        titleLabel.text = genre.name
        descriptionLabel.text = genre.description
        let color = UIColor(named: genre.colorName)?.withAlphaComponent(0.3) ?? UIColor.white.withAlphaComponent(0.08)
        contentView.backgroundColor = color
        updateFavoriteButton(isFavorited: isFavorited)
    }

    func configure(_ title: String) {
        titleLabel.text = title
        iconLabel.text = ""
        descriptionLabel.text = ""
    }

    func updateFavoriteButton(isFavorited: Bool) {
        let icon = isFavorited ? "heart.fill" : "heart"
        favoriteButton.setImage(UIImage(systemName: icon), for: .normal)
        favoriteButton.tintColor = isFavorited ? UIColor(named: "FavoriteActivePink") : UIColor.white.withAlphaComponent(0.8)
    }

    @objc private func favTapped() {
        onFavoriteTapped?()
    }
}
