//
//  RecentSearchCell.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 22.02.26.
//
import UIKit

final class RecentSearchCell: UITableViewCell {

    static let identifier = "RecentSearchCell"

    var onDeleteTapped: (() -> Void)?

    private let icon = UIImageView(image: UIImage(systemName: "clock"))
    private let titleLabel = UILabel()
    private let deleteButton = UIButton(type: .system)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {

        backgroundColor = .clear

        icon.tintColor = UIColor(white: 1, alpha: 0.5)

        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 16)

        deleteButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        deleteButton.tintColor = UIColor(white: 1, alpha: 0.6)
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [icon, titleLabel, UIView(), deleteButton])
        stack.alignment = .center
        stack.spacing = 12

        contentView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -14)
        ])
    }

    func configure(with text: String) {
        titleLabel.text = text
    }

    @objc private func deleteTapped() {
        onDeleteTapped?()
    }
}
