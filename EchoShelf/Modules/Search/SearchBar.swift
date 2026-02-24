//
//  SearchBar.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 24.02.26.
//
import UIKit

final class SearchBarView: UIView {

    var onSearch: ((String) -> Void)?
    var onTextChange: ((String) -> Void)?

    private let searchIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        iv.tintColor = UIColor.white.withAlphaComponent(0.6)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let clearButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        btn.tintColor = UIColor.white.withAlphaComponent(0.6)
        btn.alpha = 0
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let textField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Search books, authors..."
        tf.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        tf.layer.cornerRadius = 20
        tf.textColor = .white
        tf.returnKeyType = .search
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupActions()
    }

    required init?(coder: NSCoder) { fatalError() }
}

private extension SearchBarView {

    func setupUI() {
        addSubview(textField)
        textField.addSubview(searchIcon)
        textField.addSubview(clearButton)

        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            textField.centerYAnchor.constraint(equalTo: centerYAnchor),
            textField.heightAnchor.constraint(equalToConstant: 44),

            searchIcon.leadingAnchor.constraint(equalTo: textField.leadingAnchor, constant: 14),
            searchIcon.centerYAnchor.constraint(equalTo: textField.centerYAnchor),

            clearButton.trailingAnchor.constraint(equalTo: textField.trailingAnchor, constant: -14),
            clearButton.centerYAnchor.constraint(equalTo: textField.centerYAnchor)
        ])

        textField.delegate = self
        textField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        textField.setLeftPaddingPoints(38)
        textField.setRightPaddingPoints(38)
    }

    func setupActions() {
        clearButton.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
    }

    @objc func clearTapped() {
        textField.text = ""
        clearButton.alpha = 0
        onTextChange?("")
    }

    @objc func textChanged() {
        let text = textField.text ?? ""
        clearButton.alpha = text.isEmpty ? 0 : 1
        onTextChange?(text)
    }
}

extension SearchBarView: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        onSearch?(textField.text ?? "")
        textField.resignFirstResponder()
        return true
    }
}
