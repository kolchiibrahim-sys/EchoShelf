//
//  RecentSearchCell.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 22.02.26.
//
import UIKit

final class RecentSearchCell: UICollectionViewCell {

    static let identifier = "RecentSearchCell"

    var onDelete: (() -> Void)?

    private let label = UILabel()

    private let deleteButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        b.tintColor = UIColor.white.withAlphaComponent(0.5)
        return b
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = UIColor.white.withAlphaComponent(0.05)
        layer.cornerRadius = 16

        label.textColor = .white
        label.font = .systemFont(ofSize: 15, weight: .medium)

        contentView.addSubview(label)
        contentView.addSubview(deleteButton)

        label.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),
            deleteButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            deleteButton.widthAnchor.constraint(equalToConstant: 22),
            deleteButton.heightAnchor.constraint(equalToConstant: 22)
        ])

        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(with text: String) {
        label.text = text
    }

    @objc private func deleteTapped() {
        onDelete?()
    }
}
