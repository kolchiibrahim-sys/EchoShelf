//
//  GenresCell.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 24.02.26.
//
import UIKit

final class GenreCell: UICollectionViewCell {

    static let identifier = "GenreCell"

    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 13, weight: .semibold)
        lbl.textColor = .white
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    override var isSelected: Bool {
        didSet { updateSelectionUI() }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        contentView.layer.cornerRadius = 18
        contentView.backgroundColor = UIColor.white.withAlphaComponent(0.06)

        contentView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }

    private func updateSelectionUI() {
        if isSelected {
            contentView.backgroundColor = UIColor.systemPurple
        } else {
            contentView.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        }
    }

    func configure(_ title: String) {
        titleLabel.text = title
    }
}

