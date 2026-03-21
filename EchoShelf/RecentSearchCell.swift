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

    private let historyIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "clock.arrow.circlepath"))
        iv.tintColor = UIColor.white.withAlphaComponent(0.4)
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.widthAnchor.constraint(equalToConstant: 18).isActive = true
        iv.heightAnchor.constraint(equalToConstant: 18).isActive = true
        return iv
    }()

    private let label: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .white
        lbl.font = .systemFont(ofSize: 15, weight: .medium)
        return lbl
    }()

    private let deleteButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "xmark"), for: .normal)
        btn.tintColor = UIColor.white.withAlphaComponent(0.4)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.widthAnchor.constraint(equalToConstant: 28).isActive = true
        btn.heightAnchor.constraint(equalToConstant: 28).isActive = true
        return btn
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        backgroundColor = .clear

        let stack = UIStackView(arrangedSubviews: [historyIcon, label, UIView(), deleteButton])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])

        // Bottom divider
        let divider = UIView()
        divider.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        divider.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(divider)
        NSLayoutConstraint.activate([
            divider.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            divider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            divider.heightAnchor.constraint(equalToConstant: 0.5)
        ])

        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
    }

    func configure(with text: String) {
        label.text = text
    }

    @objc private func deleteTapped() {
        onDelete?()
    }
}
