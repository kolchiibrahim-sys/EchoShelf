//
//  ForgotPasswordViewController.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 26.02.26.
//
import UIKit

final class ForgotPasswordViewController: UIViewController {

    var onBackToSignIn: (() -> Void)?

    private let logoContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.42, green: 0.38, blue: 0.93, alpha: 1.0)
        view.layer.cornerRadius = 20
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "book.fill")
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let appNameLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "EchoShelf"
        lbl.font = .systemFont(ofSize: 22, weight: .bold)
        lbl.textColor = .white
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let iconContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.42, green: 0.38, blue: 0.93, alpha: 0.2)
        view.layer.cornerRadius = 36
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let lockIconImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "lock.rotation")
        iv.tintColor = UIColor(red: 0.42, green: 0.38, blue: 0.93, alpha: 1.0)
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Forgot Password?"
        lbl.font = .systemFont(ofSize: 34, weight: .bold)
        lbl.textColor = .white
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let subtitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Enter your email and we'll send you a reset link."
        lbl.font = .systemFont(ofSize: 16, weight: .regular)
        lbl.textColor = UIColor.white.withAlphaComponent(0.6)
        lbl.numberOfLines = 0
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let emailTextField: UITextField = {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(
            string: "Email Address",
            attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.5)]
        )
        tf.textColor = .white
        tf.backgroundColor = UIColor(red: 0.16, green: 0.17, blue: 0.24, alpha: 1.0)
        tf.layer.cornerRadius = 16
        tf.keyboardType = .emailAddress
        tf.autocapitalizationType = .none
        tf.leftViewMode = .always
        tf.translatesAutoresizingMaskIntoConstraints = false
        let icon = UIImageView(image: UIImage(systemName: "envelope"))
        icon.tintColor = UIColor.white.withAlphaComponent(0.5)
        icon.frame = CGRect(x: 0, y: 0, width: 44, height: 24)
        icon.contentMode = .center
        tf.leftView = icon
        return tf
    }()

    private let sendButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Send Reset Link →", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        btn.backgroundColor = UIColor(red: 0.42, green: 0.38, blue: 0.93, alpha: 1.0)
        btn.layer.cornerRadius = 28
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let backToSignInLabel: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 1
        lbl.textAlignment = .center
        let fullText = "Remember your password? Sign In"
        let attributed = NSMutableAttributedString(
            string: fullText,
            attributes: [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: UIColor.white.withAlphaComponent(0.5)
            ]
        )
        let purple = UIColor(red: 0.42, green: 0.38, blue: 0.93, alpha: 1.0)
        if let range = fullText.range(of: "Sign In") {
            attributed.addAttribute(.foregroundColor, value: purple, range: NSRange(range, in: fullText))
        }
        lbl.attributedText = attributed
        lbl.isUserInteractionEnabled = true
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let successView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.09, green: 0.10, blue: 0.16, alpha: 1.0)
        view.alpha = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let successIconContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.42, green: 0.38, blue: 0.93, alpha: 0.2)
        view.layer.cornerRadius = 44
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let successIconImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "paperplane.fill")
        iv.tintColor = UIColor(red: 0.42, green: 0.38, blue: 0.93, alpha: 1.0)
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let successTitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Check Your Email"
        lbl.font = .systemFont(ofSize: 28, weight: .bold)
        lbl.textColor = .white
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let successSubtitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "We've sent a password reset link to your email address."
        lbl.font = .systemFont(ofSize: 16)
        lbl.textColor = UIColor.white.withAlphaComponent(0.6)
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let backToLoginButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Back to Sign In", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        btn.backgroundColor = UIColor(red: 0.42, green: 0.38, blue: 0.93, alpha: 1.0)
        btn.layer.cornerRadius = 28
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
    }

    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.09, green: 0.10, blue: 0.16, alpha: 1.0)

        view.addSubview(logoContainerView)
        logoContainerView.addSubview(logoImageView)
        view.addSubview(appNameLabel)
        view.addSubview(iconContainerView)
        iconContainerView.addSubview(lockIconImageView)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(emailTextField)
        view.addSubview(sendButton)
        view.addSubview(backToSignInLabel)

        view.addSubview(successView)
        successView.addSubview(successIconContainer)
        successIconContainer.addSubview(successIconImageView)
        successView.addSubview(successTitleLabel)
        successView.addSubview(successSubtitleLabel)
        successView.addSubview(backToLoginButton)

        NSLayoutConstraint.activate([
            // Logo container
            logoContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 4),
            logoContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -50),
            logoContainerView.widthAnchor.constraint(equalToConstant: 40),
            logoContainerView.heightAnchor.constraint(equalToConstant: 40),

            // Logo image
            logoImageView.centerXAnchor.constraint(equalTo: logoContainerView.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: logoContainerView.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 22),
            logoImageView.heightAnchor.constraint(equalToConstant: 22),

            // App name label
            appNameLabel.centerYAnchor.constraint(equalTo: logoContainerView.centerYAnchor),
            appNameLabel.leadingAnchor.constraint(equalTo: logoContainerView.trailingAnchor, constant: 8),

            // Lock icon container
            iconContainerView.topAnchor.constraint(equalTo: logoContainerView.bottomAnchor, constant: 32),
            iconContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            iconContainerView.widthAnchor.constraint(equalToConstant: 72),
            iconContainerView.heightAnchor.constraint(equalToConstant: 72),

            // Lock icon image
            lockIconImageView.centerXAnchor.constraint(equalTo: iconContainerView.centerXAnchor),
            lockIconImageView.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor),
            lockIconImageView.widthAnchor.constraint(equalToConstant: 36),
            lockIconImageView.heightAnchor.constraint(equalToConstant: 36),

            // Title label
            titleLabel.topAnchor.constraint(equalTo: iconContainerView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),

            // Subtitle label
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            // Email text field
            emailTextField.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 32),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            emailTextField.heightAnchor.constraint(equalToConstant: 58),

            // Send button
            sendButton.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            sendButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            sendButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            sendButton.heightAnchor.constraint(equalToConstant: 58),

            // Back to sign in label
            backToSignInLabel.topAnchor.constraint(equalTo: sendButton.bottomAnchor, constant: 28),
            backToSignInLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            // Success view (full screen overlay)
            successView.topAnchor.constraint(equalTo: view.topAnchor),
            successView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            successView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            successView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Success icon container
            successIconContainer.centerXAnchor.constraint(equalTo: successView.centerXAnchor),
            successIconContainer.centerYAnchor.constraint(equalTo: successView.centerYAnchor, constant: -80),
            successIconContainer.widthAnchor.constraint(equalToConstant: 88),
            successIconContainer.heightAnchor.constraint(equalToConstant: 88),

            // Success icon image
            successIconImageView.centerXAnchor.constraint(equalTo: successIconContainer.centerXAnchor),
            successIconImageView.centerYAnchor.constraint(equalTo: successIconContainer.centerYAnchor),
            successIconImageView.widthAnchor.constraint(equalToConstant: 44),
            successIconImageView.heightAnchor.constraint(equalToConstant: 44),

            // Success title
            successTitleLabel.topAnchor.constraint(equalTo: successIconContainer.bottomAnchor, constant: 24),
            successTitleLabel.leadingAnchor.constraint(equalTo: successView.leadingAnchor, constant: 24),
            successTitleLabel.trailingAnchor.constraint(equalTo: successView.trailingAnchor, constant: -24),

            // Success subtitle
            successSubtitleLabel.topAnchor.constraint(equalTo: successTitleLabel.bottomAnchor, constant: 12),
            successSubtitleLabel.leadingAnchor.constraint(equalTo: successView.leadingAnchor, constant: 32),
            successSubtitleLabel.trailingAnchor.constraint(equalTo: successView.trailingAnchor, constant: -32),

            // Back to login button
            backToLoginButton.topAnchor.constraint(equalTo: successSubtitleLabel.bottomAnchor, constant: 40),
            backToLoginButton.leadingAnchor.constraint(equalTo: successView.leadingAnchor, constant: 24),
            backToLoginButton.trailingAnchor.constraint(equalTo: successView.trailingAnchor, constant: -24),
            backToLoginButton.heightAnchor.constraint(equalToConstant: 58)
        ])
    }

    private func setupActions() {
        sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
        backToLoginButton.addTarget(self, action: #selector(backToSignInTapped), for: .touchUpInside)
        let tap = UITapGestureRecognizer(target: self, action: #selector(backToSignInTapped))
        backToSignInLabel.addGestureRecognizer(tap)
        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(dismissTap)
    }

    @objc private func sendTapped() {
        guard let email = emailTextField.text, !email.isEmpty else {
            let alert = UIAlertController(title: "Missing Email", message: "Please enter your email address.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        AuthService.shared.resetPassword(email: email) { [weak self] result in
            switch result {
            case .success:
                self?.showSuccessState()
            case .failure(let error):
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
            }
        }
    }

    @objc private func backToSignInTapped() {
        onBackToSignIn?()
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func showSuccessState() {
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut) {
            self.successView.alpha = 1
        }
    }
}
