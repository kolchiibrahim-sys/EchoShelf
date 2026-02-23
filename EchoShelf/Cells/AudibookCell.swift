//
//  AudibookCell.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 22.02.26.
//
import UIKit

final class AudiobookCell: UITableViewCell {

    static let identifier = "AudiobookCell"

    private let coverView: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 12
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        return v
    }()

    private let iconView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "building.columns.fill"))
        iv.tintColor = .white
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 16, weight: .bold)
        lbl.textColor = .white
        lbl.numberOfLines = 2
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let authorLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 14)
        lbl.textColor = UIColor(white: 1, alpha: 0.6)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let textStack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 6
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {

        contentView.addSubview(coverView)
        coverView.addSubview(iconView)
        contentView.addSubview(textStack)

        textStack.addArrangedSubview(titleLabel)
        textStack.addArrangedSubview(authorLabel)

        NSLayoutConstraint.activate([

            coverView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            coverView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            coverView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            coverView.widthAnchor.constraint(equalToConstant: 70),

            iconView.centerXAnchor.constraint(equalTo: coverView.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: coverView.centerYAnchor),
            iconView.heightAnchor.constraint(equalToConstant: 28),
            iconView.widthAnchor.constraint(equalToConstant: 28),

            textStack.leadingAnchor.constraint(equalTo: coverView.trailingAnchor, constant: 16),
            textStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textStack.centerYAnchor.constraint(equalTo: coverView.centerYAnchor)
        ])
    }

    func configure(with book: Audiobook) {
        titleLabel.text = book.title

        if let author = book.authors?.first {
            authorLabel.text = "\(author.firstName ?? "") \(author.lastName ?? "")"
        } else {
            authorLabel.text = "Unknown Author"
        }
    }
}
