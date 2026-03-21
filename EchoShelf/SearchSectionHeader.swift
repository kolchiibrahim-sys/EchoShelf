//
//  SearchSectionHeader.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 24.02.26.
//
import UIKit

final class SearchSectionHeaderView: UICollectionReusableView {

    static let identifier = "SearchSectionHeaderView"

    var onClearAll: (() -> Void)?

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let clearAllButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Clear All", for: .normal)
        btn.setTitleColor(UIColor.systemPurple, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        btn.isHidden = true
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        clearAllButton.isHidden = true
        onClearAll = nil
    }

    private func setupUI() {
        backgroundColor = .clear
        addSubview(titleLabel)
        addSubview(clearAllButton)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            clearAllButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            clearAllButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        clearAllButton.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
    }

    func configure(_ title: String, showClearAll: Bool = false) {
        titleLabel.text = title
        clearAllButton.isHidden = !showClearAll
    }

    @objc private func clearTapped() {
        onClearAll?()
    }
}
