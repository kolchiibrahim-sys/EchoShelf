//
//  HomeHeaderView.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 24.02.26.
//
import UIKit

final class HomeHeaderView: UIView {

    private let greetingLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "GOOD MORNING,"
        lbl.font = .systemFont(ofSize: 13, weight: .medium)
        lbl.textColor = UIColor.white.withAlphaComponent(0.6)
        return lbl
    }()

    private let nameLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Alex."
        lbl.font = .systemFont(ofSize: 28, weight: .bold)
        lbl.textColor = .white
        return lbl
    }()

    private let searchButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        b.tintColor = .black
        b.backgroundColor = .white
        b.layer.cornerRadius = 20
        return b
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup() {

        let textStack = UIStackView(arrangedSubviews: [greetingLabel, nameLabel])
        textStack.axis = .vertical
        textStack.spacing = 2

        let hStack = UIStackView(arrangedSubviews: [textStack, UIView(), searchButton])
        hStack.alignment = .center
        hStack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(hStack)

        searchButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            hStack.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            hStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            hStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            hStack.bottomAnchor.constraint(equalTo: bottomAnchor),

            searchButton.widthAnchor.constraint(equalToConstant: 40),
            searchButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
}
