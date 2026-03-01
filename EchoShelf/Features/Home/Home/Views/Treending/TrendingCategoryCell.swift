//
//  TrendingCategoryCell.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 01.03.26.
//
import UIKit

struct TrendingCategory {
    let title: String
    let icon: String
    let colors: [UIColor]
}

final class TrendingCategoryCell: UICollectionViewCell {

    static let identifier = "TrendingCategoryCell"

    private let gradientLayer = CAGradientLayer()

    private let iconLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 28)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 18, weight: .bold)
        lbl.textColor = .white
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

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
        contentView.layer.cornerRadius = 20
        contentView.clipsToBounds = true

        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        contentView.layer.insertSublayer(gradientLayer, at: 0)

        contentView.addSubview(iconLabel)
        contentView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            iconLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            iconLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),

            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }

    func configure(with category: TrendingCategory) {
        titleLabel.text = category.title
        iconLabel.text = category.icon
        gradientLayer.colors = category.colors.map { $0.cgColor }
    }
}
