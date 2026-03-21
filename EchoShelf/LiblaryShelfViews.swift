//
//  LiblaryShelfViews.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 05.03.26.
//

import UIKit

final class LibraryShelfHeader: UICollectionReusableView {

    static let identifier = "LibraryShelfHeader"

    private let iconView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor   = UIColor(hex: "#C8A96E")
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font      = .systemFont(ofSize: 18, weight: .bold)
        lbl.textColor = UIColor(hex: "#E8D5B0")
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let countLabel: UILabel = {
        let lbl = UILabel()
        lbl.font      = .systemFont(ofSize: 12, weight: .medium)
        lbl.textColor = UIColor(hex: "#C8A96E").withAlphaComponent(0.7)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let divider: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hex: "#C8A96E").withAlphaComponent(0.2)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        addSubview(iconView)
        addSubview(titleLabel)
        addSubview(countLabel)
        addSubview(divider)

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            iconView.bottomAnchor.constraint(equalTo: divider.topAnchor, constant: -10),
            iconView.widthAnchor.constraint(equalToConstant: 16),
            iconView.heightAnchor.constraint(equalToConstant: 16),

            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 8),
            titleLabel.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),

            countLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8),
            countLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),

            divider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            divider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            divider.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
            divider.heightAnchor.constraint(equalToConstant: 1)
        ])
    }

    func configure(title: String, icon: String, count: Int) {
        titleLabel.text = title
        iconView.image  = UIImage(systemName: icon)
        countLabel.text = "\(count) books"
    }
}

final class ShelfWoodView: UICollectionReusableView {

    static let identifier = "ShelfWoodView"

    private let woodLayer   = CAGradientLayer()
    private let topGlow     = CALayer()
    private let bottomShadow = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        woodLayer.frame      = bounds
        topGlow.frame        = CGRect(x: 0, y: 0, width: bounds.width, height: 3)
        bottomShadow.frame   = CGRect(x: 0, y: bounds.height - 8, width: bounds.width, height: 8)
    }

    private func setupLayers() {
        woodLayer.colors = [
            UIColor(hex: "#7B5B2A").cgColor,
            UIColor(hex: "#6B4E22").cgColor,
            UIColor(hex: "#5A3E18").cgColor,
            UIColor(hex: "#4A3010").cgColor,
        ]
        woodLayer.locations = [0, 0.3, 0.7, 1]
        woodLayer.startPoint = CGPoint(x: 0, y: 0)
        woodLayer.endPoint   = CGPoint(x: 0, y: 1)
        layer.insertSublayer(woodLayer, at: 0)

        topGlow.backgroundColor = UIColor.white.withAlphaComponent(0.18).cgColor
        layer.addSublayer(topGlow)
        bottomShadow.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.45).cgColor
        ]
        bottomShadow.startPoint = CGPoint(x: 0, y: 0)
        bottomShadow.endPoint   = CGPoint(x: 0, y: 1)
        layer.addSublayer(bottomShadow)
    }
}

final class LibraryEmptyCell: UICollectionViewCell {

    static let identifier = "LibraryEmptyCell"

    private let iconView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "books.vertical"))
        iv.tintColor     = UIColor(hex: "#C8A96E").withAlphaComponent(0.35)
        iv.contentMode   = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let messageLabel: UILabel = {
        let lbl = UILabel()
        lbl.text          = "This shelf is empty"
        lbl.font          = .systemFont(ofSize: 13, weight: .medium)
        lbl.textColor     = UIColor(hex: "#C8A96E").withAlphaComponent(0.5)
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let subLabel: UILabel = {
        let lbl = UILabel()
        lbl.text          = "Open a book to add it here"
        lbl.font          = .systemFont(ofSize: 11)
        lbl.textColor     = UIColor(hex: "#C8A96E").withAlphaComponent(0.3)
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        contentView.addSubview(iconView)
        contentView.addSubview(messageLabel)
        contentView.addSubview(subLabel)

        NSLayoutConstraint.activate([
            iconView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -20),
            iconView.widthAnchor.constraint(equalToConstant: 40),
            iconView.heightAnchor.constraint(equalToConstant: 40),

            messageLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 12),
            messageLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            subLabel.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 4),
            subLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
    }
}
