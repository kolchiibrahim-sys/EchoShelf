//
//  DetailButton.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 24.02.26.
//
import UIKit

final class DetailButton: UIButton {

    init(systemName: String) {
        super.init(frame: .zero)

        setImage(UIImage(systemName: systemName), for: .normal)
        tintColor = .white
        backgroundColor = UIColor.white.withAlphaComponent(0.08)

        layer.cornerRadius = 22
        translatesAutoresizingMaskIntoConstraints = false

        widthAnchor.constraint(equalToConstant: 44).isActive = true
        heightAnchor.constraint(equalToConstant: 44).isActive = true
    }

    required init?(coder: NSCoder) { fatalError() }
}
