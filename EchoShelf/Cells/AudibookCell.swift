//
//  AudibookCell.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 22.02.26.
//
import UIKit
import Kingfisher

final class AudiobookCell: UITableViewCell {

    static let identifier = "AudiobookCell"

    private let coverImageView: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 12
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.backgroundColor = UIColor.white.withAlphaComponent(0.1)
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
        lbl.textColor = UIColor(white: 1, alpha: 0.7)
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

        contentView.addSubview(coverImageView)
        contentView.addSubview(textStack)

        textStack.addArrangedSubview(titleLabel)
        textStack.addArrangedSubview(authorLabel)

        NSLayoutConstraint.activate([
            coverImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            coverImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            coverImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            coverImageView.widthAnchor.constraint(equalToConstant: 70),

            textStack.leadingAnchor.constraint(equalTo: coverImageView.trailingAnchor, constant: 16),
            textStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textStack.centerYAnchor.constraint(equalTo: coverImageView.centerYAnchor)
        ])
    }

    func configure(with book: Audiobook) {

        titleLabel.text = book.title

        if let author = book.authors?.first {
            authorLabel.text = "\(author.firstName ?? "") \(author.lastName ?? "")"
        } else {
            authorLabel.text = "Unknown Author"
        }

        if let cover = book.googleCoverURL,
           let url = URL(string: cover) {
            coverImageView.kf.setImage(with: url)
        } else {
            coverImageView.image = UIImage(systemName: "book.fill")
        }
    }
}
