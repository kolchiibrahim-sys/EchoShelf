//
//  BookSpinCell.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 05.03.26.
//

import UIKit
import Kingfisher

final class BookSpineCell: UICollectionViewCell {

    static let identifier = "BookSpineCell"
    private let spineView = UIView()
    private let gradientLayer = CAGradientLayer()
    private let innerShadowLayer = CAGradientLayer()
    private let topEdgeLayer = CALayer()
    private let rightEdgeLayer = CALayer()

    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 9, weight: .semibold)
        lbl.textColor = UIColor.white.withAlphaComponent(0.85)
        lbl.numberOfLines = 6
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let progressBar: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let progressFill: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(red: 0.95, green: 0.75, blue: 0.3, alpha: 0.9)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private var progressFillHeight: NSLayoutConstraint!

    private static let spineColors: [[(UIColor, UIColor)]] = [
        [(.init(hex: "#7B3F00"), .init(hex: "#5C2D00"))],   // dark brown
        [(.init(hex: "#1B3A5C"), .init(hex: "#0F2540"))],   // navy
        [(.init(hex: "#2D5A27"), .init(hex: "#1A3A16"))],   // forest green
        [(.init(hex: "#6B2D3E"), .init(hex: "#4A1C29"))],   // burgundy
        [(.init(hex: "#4A3728"), .init(hex: "#2E2018"))],   // leather
        [(.init(hex: "#1A3A4A"), .init(hex: "#0F2530"))],   // teal dark
        [(.init(hex: "#5C3D11"), .init(hex: "#3D2808"))],   // walnut
        [(.init(hex: "#3B2F4A"), .init(hex: "#251E30"))],   // deep purple
        [(.init(hex: "#4A1942"), .init(hex: "#2E0F28"))],   // plum
        [(.init(hex: "#1C3A2A"), .init(hex: "#0F2218"))],   // dark teal
        [(.init(hex: "#5C1A1A"), .init(hex: "#3A0F0F"))],   // deep red
        [(.init(hex: "#2A3A1C"), .init(hex: "#182210"))],   // olive
    ]

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }


    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame    = spineView.bounds
        innerShadowLayer.frame = CGRect(x: 0, y: 0, width: 10, height: spineView.bounds.height)
        topEdgeLayer.frame     = CGRect(x: 0, y: 0, width: spineView.bounds.width, height: 2)
        rightEdgeLayer.frame   = CGRect(x: spineView.bounds.width - 2, y: 0, width: 2, height: spineView.bounds.height)
    }

    private func setupUI() {
        contentView.layer.shadowColor   = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.55
        contentView.layer.shadowRadius  = 5
        contentView.layer.shadowOffset  = CGSize(width: 4, height: 3)
        contentView.layer.shouldRasterize      = true
        contentView.layer.rasterizationScale   = UIScreen.main.scale

        spineView.layer.cornerRadius   = 2
        spineView.layer.maskedCorners  = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        spineView.clipsToBounds        = true
        spineView.translatesAutoresizingMaskIntoConstraints = false
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint   = CGPoint(x: 1, y: 0.5)
        spineView.layer.insertSublayer(gradientLayer, at: 0)
        innerShadowLayer.startPoint = CGPoint(x: 0, y: 0.5)
        innerShadowLayer.endPoint   = CGPoint(x: 1, y: 0.5)
        innerShadowLayer.colors = [
            UIColor.black.withAlphaComponent(0.4).cgColor,
            UIColor.clear.cgColor
        ]
        spineView.layer.addSublayer(innerShadowLayer)
        topEdgeLayer.backgroundColor = UIColor.white.withAlphaComponent(0.2).cgColor
        spineView.layer.addSublayer(topEdgeLayer)
        rightEdgeLayer.backgroundColor = UIColor.black.withAlphaComponent(0.25).cgColor
        spineView.layer.addSublayer(rightEdgeLayer)

        contentView.addSubview(spineView)
        spineView.addSubview(titleLabel)
        spineView.addSubview(progressBar)
        progressBar.addSubview(progressFill)
        titleLabel.transform = CGAffineTransform(rotationAngle: -.pi / 2)

        progressFillHeight = progressFill.heightAnchor.constraint(equalToConstant: 0)

        NSLayoutConstraint.activate([
            spineView.topAnchor.constraint(equalTo: contentView.topAnchor),
            spineView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            spineView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            spineView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            titleLabel.centerXAnchor.constraint(equalTo: spineView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: spineView.centerYAnchor),
            titleLabel.widthAnchor.constraint(equalToConstant: 120),

            progressBar.leadingAnchor.constraint(equalTo: spineView.leadingAnchor),
            progressBar.trailingAnchor.constraint(equalTo: spineView.trailingAnchor),
            progressBar.bottomAnchor.constraint(equalTo: spineView.bottomAnchor),
            progressBar.heightAnchor.constraint(equalToConstant: 4),

            progressFill.leadingAnchor.constraint(equalTo: progressBar.leadingAnchor),
            progressFill.trailingAnchor.constraint(equalTo: progressBar.trailingAnchor),
            progressFill.bottomAnchor.constraint(equalTo: progressBar.bottomAnchor),
            progressFillHeight
        ])
    }

    func configure(with item: LibraryItem, index: Int) {
        titleLabel.text = item.title

        let palette = Self.spineColors[index % Self.spineColors.count][0]
        gradientLayer.colors = [
            palette.0.withAlphaComponent(0.95).cgColor,
            palette.1.cgColor
        ]

        let progress = item.readingProgress
        progressFillHeight.constant = progress > 0 ? 4 : 0
        progressFill.alpha = progress > 0 ? 1 : 0

        if progress >= 0.99 {
            progressFill.backgroundColor = UIColor(hex: "#4CAF50").withAlphaComponent(0.9)
        } else {
            progressFill.backgroundColor = UIColor(red: 0.95, green: 0.75, blue: 0.3, alpha: 0.9)
        }
    }

    func animatePullOut(completion: @escaping () -> Void) {
        UIView.animate(
            withDuration: 0.28,
            delay: 0,
            usingSpringWithDamping: 0.65,
            initialSpringVelocity: 0.5,
            options: .curveEaseOut
        ) {
            self.contentView.transform = CGAffineTransform(translationX: 0, y: -22)
            self.contentView.layer.shadowRadius  = 14
            self.contentView.layer.shadowOpacity = 0.7
        } completion: { _ in
            completion()
            UIView.animate(withDuration: 0.22, delay: 0.05) {
                self.contentView.transform           = .identity
                self.contentView.layer.shadowRadius  = 5
                self.contentView.layer.shadowOpacity = 0.55
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        contentView.transform = .identity
    }
}
