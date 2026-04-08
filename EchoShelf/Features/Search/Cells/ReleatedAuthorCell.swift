//
//  ReleatedAuthorCell.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 24.02.26.
//
import UIKit
import Kingfisher

final class RelatedAuthorCell: UICollectionViewCell {

    static let identifier = "RelatedAuthorCell"

    private lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 40
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = UIColor(named: "PrimaryGradientStart")?.withAlphaComponent(0.3)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private lazy var initialsLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .white
        lbl.font = .systemFont(ofSize: 28, weight: .bold)
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private lazy var nameLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = UIColor(named: "OnDarkTextPrimary")
        lbl.font = .systemFont(ofSize: 13)
        lbl.textAlignment = .center
        lbl.numberOfLines = 2
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        initialsLabel.text = nil
        imageView.image = nil
        imageView.kf.cancelDownloadTask()
    }

    private func setupUI() {
        contentView.addSubview(imageView)
        imageView.addSubview(initialsLabel)
        contentView.addSubview(nameLabel)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),

            initialsLabel.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            initialsLabel.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),

            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 6),
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    func configure(with author: Author?) {
        guard let author else {
            nameLabel.text = "Unknown Author"
            initialsLabel.text = "?"
            return
        }

        let first = author.firstName ?? ""
        let last  = author.lastName ?? ""
        nameLabel.text = "\(first) \(last)".trimmingCharacters(in: .whitespaces)

        let firstInitial = first.first?.uppercased() ?? ""
        let lastInitial  = last.first?.uppercased() ?? ""
        let initials = firstInitial + lastInitial
        initialsLabel.text = initials.isEmpty ? "A" : initials

        fetchAndSetPhoto(firstName: first, lastName: last)
    }

    private func fetchAndSetPhoto(firstName: String, lastName: String) {
        let name = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }

        let urlString = "https://openlibrary.org/search/authors.json?q=\(name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data,
                  let json = try? JSONDecoder().decode(OpenLibrarySearchResponse.self, from: data),
                  let doc = json.docs.first else { return }
            let olid = doc.key.replacingOccurrences(of: "/authors/", with: "")
            let photoURL = URL(string: "https://covers.openlibrary.org/a/olid/\(olid)-M.jpg")
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.imageView.kf.setImage(with: photoURL, placeholder: nil) { result in
                    if case .success = result {
                        self.initialsLabel.isHidden = true
                    }
                }
            }
        }.resume()
    }
}
