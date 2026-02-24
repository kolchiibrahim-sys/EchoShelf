//
//  SearchSectionHeader.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 24.02.26.
//
import UIKit

final class SearchSectionHeaderView: UICollectionReusableView {

    static let identifier = "SearchSectionHeaderView"

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let divider: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(titleLabel)
        addSubview(divider)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),

            divider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            divider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            divider.bottomAnchor.constraint(equalTo: bottomAnchor),
            divider.heightAnchor.constraint(equalToConstant: 1)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(_ title: String) {
        titleLabel.text = title
    }
}
