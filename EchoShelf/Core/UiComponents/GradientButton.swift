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
        setTitleColor(.white, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)

        gradient.colors = [
            UIColor.systemPurple.cgColor,
            UIColor.systemPink.cgColor
        ]

        layer.insertSublayer(gradient, at: 0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = bounds
    }

    required init?(coder: NSCoder) { fatalError() }
}
