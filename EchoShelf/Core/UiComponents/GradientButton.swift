//
//  GradientButton.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 24.02.26.
//
import UIKit

final class GradientButton: UIButton {

    private let gradient = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)

        layer.cornerRadius = 28
        clipsToBounds = true
        setTitleColor(UIColor(named: "OnDarkTextPrimary")!, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)

        gradient.colors = [
            UIColor(named: "PrimaryGradientStart")!.cgColor,
            UIColor(named: "FavoriteActivePink")!.cgColor
        ]

        layer.insertSublayer(gradient, at: 0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = bounds
    }

    required init?(coder: NSCoder) { fatalError() }
}
