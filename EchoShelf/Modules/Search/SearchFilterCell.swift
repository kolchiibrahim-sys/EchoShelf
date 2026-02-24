//
//  SearchFilterCell.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 24.02.26.
//
import UIKit

final class SearchFilterCell: UICollectionViewCell {

    static let identifier = "SearchFilterCell"

    private let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {

        contentView.layer.cornerRadius = 18
        contentView.backgroundColor = UIColor.white.withAlphaComponent(0.06)

        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    func configure(title: String, isSelected: Bool) {

        titleLabel.text = title

        if isSelected {
            contentView.backgroundColor = UIColor.systemPurple
            titleLabel.textColor = .white
        } else {
            contentView.backgroundColor = UIColor.white.withAlphaComponent(0.06)
            titleLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        }
    }
}
