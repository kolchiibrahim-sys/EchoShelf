//
//  ForgotPasswordViewController.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 26.02.26.
//
import UIKit

final class ForgotPasswordViewController: UIViewController {

    var onBackToSignIn: (() -> Void)?

    private let viewModel: ForgotPasswordViewModel

    init(viewModel: ForgotPasswordViewModel = ForgotPasswordViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    private lazy var logoContainerView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(named: "PrimaryGradientStart")!
        v.layer.cornerRadius = 20
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private lazy var logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "EchoLogo")
        iv.tintColor = UIColor(named: "OnDarkTextPrimary")!
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private lazy var appNameLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "EchoShelf"
        lbl.font = .systemFont(ofSize: 22, weight: .bold)
        lbl.textColor = UIColor(named: "OnDarkTextPrimary")!
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private lazy var iconContainerView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(named: "PrimaryGradientStart")!.withAlphaComponent(0.2)
        v.layer.cornerRadius = 36
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private lazy var lockIconImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "lock.rotation")
        iv.tintColor = UIColor(named: "PrimaryGradientStart")!
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private lazy var titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Forgot Password?"
        lbl.font = .systemFont(ofSize: 34, weight: .bold)
        lbl.textColor = UIColor(named: "OnDarkTextPrimary")!
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private lazy var subtitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Enter your email and we'll send you a reset link."
        lbl.font = .systemFont(ofSize: 16)
        lbl.textColor = UIColor(named: "OnDarkTextSecondary")!
        lbl.numberOfLines = 0
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private lazy var emailTextField: UITextField = {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(
            string: "Email Address",
            attributes: [.foregroundColor: UIColor(named: "TabTextInactive")!]
        )
        tf.textColor = UIColor(named: "OnDarkTextPrimary")!
        tf.backgroundColor = UIColor(named: "TextFieldBackground")!
        tf.layer.cornerRadius = 16
        tf.keyboardType = .emailAddress
        tf.autocapitalizationType = .none
        tf.leftViewMode = .always
        tf.translatesAutoresizingMaskIntoConstraints = false
        let container = UIView(frame: CGRect(x: 0,
                                             y: 0,
                                             width: 52,
                                             height: 24))
        let icon = UIImageView(image: UIImage(systemName: "envelope"))
        icon.tintColor = UIColor(named: "TabTextInactive")!
        icon.frame = CGRect(x: 16,
                            y: 0,
                            width: 22,
                            height: 24)
        icon.contentMode = .scaleAspectFit
        container.addSubview(icon)
        tf.leftView = container
        return tf
    }()

    private lazy var sendButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Send Reset Link →"
        config.baseForegroundColor = UIColor(named: "OnDarkTextPrimary")!
        config.baseBackgroundColor = UIColor(named: "PrimaryGradientStart")!
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attrs in
            var a = attrs; a.font = UIFont.systemFont(ofSize: 18,
                                                      weight: .semibold); return a
        }
        config.cornerStyle = .capsule
        let btn = UIButton(configuration: config)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .medium)
        ai.color = UIColor(named: "OnDarkTextPrimary")!
        ai.hidesWhenStopped = true
        ai.translatesAutoresizingMaskIntoConstraints = false
        return ai
    }()

    private lazy var backToSignInLabel: UILabel = {
        let lbl = UILabel()
        let fullText = "Remember your password? Sign In"
        let attributed = NSMutableAttributedString(
            string: fullText,
            attributes: [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: UIColor(named: "TabTextInactive")!
            ]
        )
        let purple = UIColor(named: "PrimaryGradientStart")!
        if let r = fullText.range(of: "Sign In") {
            attributed.addAttribute(.foregroundColor,
                                    value: purple,
                                    range: NSRange(r, in: fullText))
        }
        lbl.attributedText = attributed
        lbl.textAlignment = .center
        lbl.isUserInteractionEnabled = true
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private lazy var successView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(named: "AppBackground")!
        v.alpha = 0
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private lazy var successIconContainer: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(named: "PrimaryGradientStart")!.withAlphaComponent(0.2)
        v.layer.cornerRadius = 44
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private lazy var successIconImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "paperplane.fill")
        iv.tintColor = UIColor(named: "PrimaryGradientStart")!
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private lazy var successTitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Check Your Email"
        lbl.font = .systemFont(ofSize: 28,
                               weight: .bold)
        lbl.textColor = UIColor(named: "OnDarkTextPrimary")!
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private lazy var successSubtitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "We've sent a password reset link to your email address."
        lbl.font = .systemFont(ofSize: 16)
        lbl.textColor = UIColor(named: "OnDarkTextSecondary")!
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private lazy var backToLoginButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Back to Sign In"
        config.baseForegroundColor = UIColor(named: "OnDarkTextPrimary")!
        config.baseBackgroundColor = UIColor(named: "PrimaryGradientStart")!
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attrs in
            var a = attrs; a.font = UIFont.systemFont(ofSize: 18,
                                                      weight: .semibold); return a
        }
        config.cornerStyle = .capsule
        let btn = UIButton(configuration: config)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        bindViewModel()
    }

    private func setupUI() {
        view.backgroundColor = UIColor(named: "AppBackground")!

        view.addSubview(logoContainerView)
        logoContainerView.addSubview(logoImageView)
        view.addSubview(appNameLabel)
        view.addSubview(iconContainerView)
        iconContainerView.addSubview(lockIconImageView)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(emailTextField)
        view.addSubview(sendButton)
        sendButton.addSubview(activityIndicator)
        view.addSubview(backToSignInLabel)
        view.addSubview(successView)
        successView.addSubview(successIconContainer)
        successIconContainer.addSubview(successIconImageView)
        successView.addSubview(successTitleLabel)
        successView.addSubview(successSubtitleLabel)
        successView.addSubview(backToLoginButton)

        NSLayoutConstraint.activate([
            logoContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                                   constant: 4),
            logoContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor,
                                                       constant: -55),
            logoContainerView.widthAnchor.constraint(equalToConstant: 40),
            logoContainerView.heightAnchor.constraint(equalToConstant: 40),

            logoImageView.centerXAnchor.constraint(equalTo: logoContainerView.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: logoContainerView.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 22),
            logoImageView.heightAnchor.constraint(equalToConstant: 22),

            appNameLabel.centerYAnchor.constraint(equalTo: logoContainerView.centerYAnchor),
            appNameLabel.leadingAnchor.constraint(equalTo: logoContainerView.trailingAnchor,
                                                  constant: 8),

            iconContainerView.topAnchor.constraint(equalTo: logoContainerView.bottomAnchor,
                                                   constant: 32),
            iconContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                       constant: 24),
            iconContainerView.widthAnchor.constraint(equalToConstant: 72),
            iconContainerView.heightAnchor.constraint(equalToConstant: 72),

            lockIconImageView.centerXAnchor.constraint(equalTo: iconContainerView.centerXAnchor),
            lockIconImageView.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor),
            lockIconImageView.widthAnchor.constraint(equalToConstant: 36),
            lockIconImageView.heightAnchor.constraint(equalToConstant: 36),

            titleLabel.topAnchor.constraint(equalTo: iconContainerView.bottomAnchor,
                                            constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                constant: 24),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor,
                                               constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                   constant: 24),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                    constant: -24),

            emailTextField.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor,
                                                constant: 32),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                    constant: 24),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                     constant: -24),
            emailTextField.heightAnchor.constraint(equalToConstant: 58),

            sendButton.topAnchor.constraint(equalTo: emailTextField.bottomAnchor,
                                            constant: 20),
            sendButton.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                constant: 24),
            sendButton.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                 constant: -24),
            sendButton.heightAnchor.constraint(equalToConstant: 58),

            activityIndicator.centerXAnchor.constraint(equalTo: sendButton.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: sendButton.centerYAnchor),

            backToSignInLabel.topAnchor.constraint(equalTo: sendButton.bottomAnchor,
                                                   constant: 28),
            backToSignInLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            successView.topAnchor.constraint(equalTo: view.topAnchor),
            successView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            successView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            successView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            successIconContainer.centerXAnchor.constraint(equalTo: successView.centerXAnchor),
            successIconContainer.centerYAnchor.constraint(equalTo: successView.centerYAnchor,
                                                          constant: -80),
            successIconContainer.widthAnchor.constraint(equalToConstant: 88),
            successIconContainer.heightAnchor.constraint(equalToConstant: 88),

            successIconImageView.centerXAnchor.constraint(equalTo: successIconContainer.centerXAnchor),
            successIconImageView.centerYAnchor.constraint(equalTo: successIconContainer.centerYAnchor),
            successIconImageView.widthAnchor.constraint(equalToConstant: 44),
            successIconImageView.heightAnchor.constraint(equalToConstant: 44),

            successTitleLabel.topAnchor.constraint(equalTo: successIconContainer.bottomAnchor,
                                                   constant: 24),
            successTitleLabel.leadingAnchor.constraint(equalTo: successView.leadingAnchor,
                                                       constant: 24),
            successTitleLabel.trailingAnchor.constraint(equalTo: successView.trailingAnchor,
                                                        constant: -24),

            successSubtitleLabel.topAnchor.constraint(equalTo: successTitleLabel.bottomAnchor,
                                                      constant: 12),
            successSubtitleLabel.leadingAnchor.constraint(equalTo: successView.leadingAnchor,
                                                          constant: 32),
            successSubtitleLabel.trailingAnchor.constraint(equalTo: successView.trailingAnchor,
                                                           constant: -32),

            backToLoginButton.topAnchor.constraint(equalTo: successSubtitleLabel.bottomAnchor,
                                                   constant: 40),
            backToLoginButton.leadingAnchor.constraint(equalTo: successView.leadingAnchor,
                                                       constant: 24),
            backToLoginButton.trailingAnchor.constraint(equalTo: successView.trailingAnchor,
                                                        constant: -24),
            backToLoginButton.heightAnchor.constraint(equalToConstant: 58)
        ])
    }

    private func setupActions() {
        sendButton.addTarget(self,
                             action: #selector(sendTapped),
                             for: .touchUpInside)
        backToLoginButton.addTarget(self,
                                    action: #selector(backToSignInTapped),
                                    for: .touchUpInside)
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(backToSignInTapped))
        backToSignInLabel.addGestureRecognizer(tap)
        let dismissTap = UITapGestureRecognizer(target: self,
                                                action: #selector(dismissKeyboard))
        dismissTap.cancelsTouchesInView = false
        view.addGestureRecognizer(dismissTap)
    }

    private func bindViewModel() {
        viewModel.onLoadingChanged = { [weak self] isLoading in
            DispatchQueue.main.async {
                isLoading ? self?.activityIndicator.startAnimating() : self?.activityIndicator.stopAnimating()
                self?.sendButton.isEnabled = !isLoading
                self?.sendButton.alpha = isLoading ? 0.6 : 1.0
            }
        }
        viewModel.onResetSuccess = { [weak self] in
            DispatchQueue.main.async { self?.showSuccessState() }
        }
        viewModel.onError = { [weak self] message in
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Xəta",
                                              message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK",
                                              style: .default))
                self?.present(alert, animated: true)
            }
        }
    }

    @objc private func sendTapped() {
        viewModel.resetPassword(email: emailTextField.text)
    }

    @objc private func backToSignInTapped() { onBackToSignIn?() }

    @objc private func dismissKeyboard() { view.endEditing(true) }

    private func showSuccessState() {
        UIView.animate(withDuration: 0.4) { self.successView.alpha = 1 }
    }
}
