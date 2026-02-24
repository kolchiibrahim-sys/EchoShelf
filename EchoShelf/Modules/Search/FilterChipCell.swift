//
//  FilterChipCell.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 24.02.26.
//
import UIKit

final class FilterChipCell: UICollectionViewCell {

    static let identifier = "FilterChipCell"

    private let label = UILabel()

    override var isSelected: Bool {
        didSet { updateState() }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        layer.cornerRadius = 18
        backgroundColor = UIColor.white.withAlphaComponent(0.08)

        label.textColor = .white
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center

        contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(_ text: String) {
        label.text = text
    }

    private func updateState() {
        if isSelected {
            backgroundColor = UIColor.systemPurple
        } else {
            backgroundColor = UIColor.white.withAlphaComponent(0.08)
        }
    }
}
