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
    var onCancel: (() -> Void)?

    private var debounceTimer: Timer?
    private var textFieldTrailing: NSLayoutConstraint?

    private let searchIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        iv.tintColor = UIColor.white.withAlphaComponent(0.5)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let micButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "mic.fill"), for: .normal)
        btn.tintColor = UIColor.white.withAlphaComponent(0.5)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let clearButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        btn.tintColor = UIColor.white.withAlphaComponent(0.5)
        btn.alpha = 0
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let cancelButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Cancel", for: .normal)
        btn.setTitleColor(UIColor.systemPurple, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        btn.alpha = 0
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let textField: UITextField = {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(
            string: "Books, authors, narrators",
            attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.4)]
        )
        tf.backgroundColor = UIColor.white.withAlphaComponent(0.07)
        tf.layer.cornerRadius = 22
        tf.textColor = .white
        tf.returnKeyType = .search
        tf.clearButtonMode = .never
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupActions()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Public

    func setText(_ text: String) {
        textField.text = text
        clearButton.alpha = text.isEmpty ? 0 : 1
        micButton.alpha = text.isEmpty ? 1 : 0
        // Animasiyasız dərhal göstər
        cancelButton.alpha = text.isEmpty ? 0 : 1
        textFieldTrailing?.constant = text.isEmpty ? -20 : -80
        layoutIfNeeded()
    }

    func resetToHome() {
        debounceTimer?.invalidate()
        textField.text = ""
        textField.resignFirstResponder()
        clearButton.alpha = 0
        micButton.alpha = 1
        showCancelButton(false)
    }
}

// MARK: - Setup

private extension SearchBarView {

    func setupUI() {
        addSubview(cancelButton)
        addSubview(textField)
        textField.addSubview(searchIcon)
        textField.addSubview(micButton)
        textField.addSubview(clearButton)

        textFieldTrailing = textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        textFieldTrailing?.isActive = true

        NSLayoutConstraint.activate([
            cancelButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            cancelButton.centerYAnchor.constraint(equalTo: centerYAnchor),

            textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            textField.centerYAnchor.constraint(equalTo: centerYAnchor),
            textField.heightAnchor.constraint(equalToConstant: 48),

            searchIcon.leadingAnchor.constraint(equalTo: textField.leadingAnchor, constant: 16),
            searchIcon.centerYAnchor.constraint(equalTo: textField.centerYAnchor),
            searchIcon.widthAnchor.constraint(equalToConstant: 18),
            searchIcon.heightAnchor.constraint(equalToConstant: 18),

            micButton.trailingAnchor.constraint(equalTo: textField.trailingAnchor, constant: -16),
            micButton.centerYAnchor.constraint(equalTo: textField.centerYAnchor),

            clearButton.trailingAnchor.constraint(equalTo: textField.trailingAnchor, constant: -16),
            clearButton.centerYAnchor.constraint(equalTo: textField.centerYAnchor)
        ])

        textField.setLeftPaddingPoints(44)
        textField.setRightPaddingPoints(44)
        textField.delegate = self
        textField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
    }

    func setupActions() {
        clearButton.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
    }

    func showCancelButton(_ show: Bool) {
        UIView.animate(withDuration: 0.25) {
            self.cancelButton.alpha = show ? 1 : 0
            self.textFieldTrailing?.constant = show ? -80 : -20
            self.layoutIfNeeded()
        }
    }

    @objc func clearTapped() {
        debounceTimer?.invalidate()
        textField.text = ""
        clearButton.alpha = 0
        micButton.alpha = 1
        onTextChange?("")
        textField.resignFirstResponder()
    }

    @objc func cancelTapped() {
        resetToHome()
        onCancel?()
    }

    @objc func textChanged() {
        let text = textField.text ?? ""
        let isEmpty = text.isEmpty
        clearButton.alpha = isEmpty ? 0 : 1
        micButton.alpha = isEmpty ? 1 : 0
        showCancelButton(!isEmpty)
        onTextChange?(text)

        debounceTimer?.invalidate()
        guard text.count >= 2 else { return }

        debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.45, repeats: false) { [weak self] _ in
            self?.onSearch?(text)
        }
    }
}

// MARK: - UITextFieldDelegate

extension SearchBarView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        debounceTimer?.invalidate()
        onSearch?(textField.text ?? "")
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - UITextField Padding

extension UITextField {
    func setLeftPaddingPoints(_ amount: CGFloat) {
        leftView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: frame.height))
        leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount: CGFloat) {
        rightView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: frame.height))
        rightViewMode = .always
    }
}
