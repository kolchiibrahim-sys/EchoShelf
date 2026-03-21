//
//  SignInViewController.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 21.02.26.
//
import UIKit
import AuthenticationServices

final class SignInViewController: UIViewController {

    var onLoginSuccess: (() -> Void)?
    var onCreateAccount: (() -> Void)?
    var onForgotPassword: (() -> Void)?

    private let viewModel: SignInViewModel

    init(viewModel: SignInViewModel = SignInViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private lazy var contentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private lazy var logoContainerView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(named: "PrimaryGradientStart")
        v.layer.cornerRadius = 20
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private lazy var logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "EchoLogo")
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private lazy var appNameLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "EchoShelf"
        lbl.font = .systemFont(ofSize: 22, weight: .bold)
        lbl.textColor = .white
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private lazy var welcomeLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Welcome Back"
        lbl.font = .systemFont(ofSize: 34, weight: .bold)
        lbl.textColor = .white
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private lazy var subtitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Sign in to continue your listening journey."
        lbl.font = .systemFont(ofSize: 16)
        lbl.textColor = UIColor.white.withAlphaComponent(0.6)
        lbl.numberOfLines = 0
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private lazy var emailTextField: UITextField = {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(
            string: "Email Address",
            attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.5)]
        )
        tf.textColor = .white
        tf.backgroundColor = UIColor(named: "TextFieldBackground")
        tf.layer.cornerRadius = 16
        tf.keyboardType = .emailAddress
        tf.autocapitalizationType = .none
        tf.leftViewMode = .always
        tf.translatesAutoresizingMaskIntoConstraints = false
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 52, height: 24))
        let icon = UIImageView(image: UIImage(systemName: "envelope"))
        icon.tintColor = UIColor.white.withAlphaComponent(0.5)
        icon.frame = CGRect(x: 16, y: 0, width: 22, height: 24)
        icon.contentMode = .scaleAspectFit
        container.addSubview(icon)
        tf.leftView = container
        return tf
    }()

    private lazy var passwordTextField: UITextField = {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(
            string: "Password",
            attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.5)]
        )
        tf.textColor = .white
        tf.backgroundColor = UIColor(named: "TextFieldBackground")
        tf.layer.cornerRadius = 16
        tf.isSecureTextEntry = true
        tf.leftViewMode = .always
        tf.rightViewMode = .always
        tf.translatesAutoresizingMaskIntoConstraints = false
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 52, height: 24))
        let lockIcon = UIImageView(image: UIImage(systemName: "lock"))
        lockIcon.tintColor = UIColor.white.withAlphaComponent(0.5)
        lockIcon.frame = CGRect(x: 16, y: 0, width: 22, height: 24)
        lockIcon.contentMode = .scaleAspectFit
        container.addSubview(lockIcon)
        tf.leftView = container
        let eyeButton = UIButton(type: .system)
        eyeButton.setImage(UIImage(systemName: "eye"), for: .normal)
        eyeButton.tintColor = UIColor.white.withAlphaComponent(0.5)
        eyeButton.frame = CGRect(x: 0, y: 0, width: 48, height: 24)
        eyeButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        tf.rightView = eyeButton
        return tf
    }()

    private lazy var forgotPasswordButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.title = "Forgot Password?"
        config.baseForegroundColor = UIColor.white.withAlphaComponent(0.7)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attrs in
            var a = attrs; a.font = UIFont.systemFont(ofSize: 14); return a
        }
        let btn = UIButton(configuration: config)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private lazy var signInButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Sign In →"
        config.baseForegroundColor = .white
        config.baseBackgroundColor = UIColor(named: "PrimaryGradientStart")
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attrs in
            var a = attrs; a.font = UIFont.systemFont(ofSize: 18, weight: .semibold); return a
        }
        config.cornerStyle = .capsule
        let btn = UIButton(configuration: config)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .medium)
        ai.color = .white
        ai.hidesWhenStopped = true
        ai.translatesAutoresizingMaskIntoConstraints = false
        return ai
    }()

    private lazy var orLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "OR"
        lbl.font = .systemFont(ofSize: 13, weight: .medium)
        lbl.textColor = UIColor.white.withAlphaComponent(0.4)
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private lazy var leftDivider: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private lazy var rightDivider: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private lazy var appleButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Continue with Apple"
        config.image = UIImage(systemName: "apple.logo")
        config.imagePadding = 8
        config.baseForegroundColor = .white
        config.baseBackgroundColor = .black
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attrs in
            var a = attrs; a.font = UIFont.systemFont(ofSize: 17, weight: .semibold); return a
        }
        config.cornerStyle = .capsule
        let btn = UIButton(configuration: config)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private lazy var googleButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Continue with Google"
        config.baseForegroundColor = .black
        config.baseBackgroundColor = .white
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attrs in
            var a = attrs; a.font = UIFont.systemFont(ofSize: 17, weight: .semibold); return a
        }
        config.cornerStyle = .capsule
        let btn = UIButton(configuration: config)
        btn.translatesAutoresizingMaskIntoConstraints = false
        let gLabel = UILabel()
        gLabel.text = "G"
        gLabel.font = .systemFont(ofSize: 18, weight: .bold)
        gLabel.textColor = UIColor(named: "AccentColor") ?? .systemBlue
        gLabel.translatesAutoresizingMaskIntoConstraints = false
        btn.addSubview(gLabel)
        NSLayoutConstraint.activate([
            gLabel.leadingAnchor.constraint(equalTo: btn.leadingAnchor, constant: 24),
            gLabel.centerYAnchor.constraint(equalTo: btn.centerYAnchor)
        ])
        return btn
    }()

    private lazy var createAccountButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Create Account"
        config.baseForegroundColor = .white
        config.baseBackgroundColor = UIColor.white.withAlphaComponent(0.05)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attrs in
            var a = attrs; a.font = UIFont.systemFont(ofSize: 17, weight: .semibold); return a
        }
        config.cornerStyle = .capsule
        let btn = UIButton(configuration: config)
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.white.withAlphaComponent(0.25).cgColor
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private lazy var termsLabel: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 0
        lbl.textAlignment = .center
        lbl.isUserInteractionEnabled = true
        lbl.translatesAutoresizingMaskIntoConstraints = false
        let fullText = "By signing in, you agree to our Terms of Service and Privacy Policy."
        let attributed = NSMutableAttributedString(
            string: fullText,
            attributes: [
                .font: UIFont.systemFont(ofSize: 13),
                .foregroundColor: UIColor.white.withAlphaComponent(0.5)
            ]
        )
        let purple = UIColor(named: "PrimaryGradientStart") ?? .systemPurple
        if let r = fullText.range(of: "Terms of Service") {
            attributed.addAttribute(.foregroundColor, value: purple, range: NSRange(r, in: fullText))
        }
        if let r = fullText.range(of: "Privacy Policy") {
            attributed.addAttribute(.foregroundColor, value: purple, range: NSRange(r, in: fullText))
        }
        lbl.attributedText = attributed
        return lbl
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        bindViewModel()
    }

    private func setupUI() {
        view.backgroundColor = UIColor(named: "AppBackground")
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(logoContainerView)
        logoContainerView.addSubview(logoImageView)
        contentView.addSubview(appNameLabel)
        contentView.addSubview(welcomeLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(emailTextField)
        contentView.addSubview(passwordTextField)
        contentView.addSubview(forgotPasswordButton)
        contentView.addSubview(signInButton)
        signInButton.addSubview(activityIndicator)
        contentView.addSubview(leftDivider)
        contentView.addSubview(orLabel)
        contentView.addSubview(rightDivider)
        contentView.addSubview(appleButton)
        contentView.addSubview(googleButton)
        contentView.addSubview(createAccountButton)
        contentView.addSubview(termsLabel)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            logoContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 60),
            logoContainerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: -55),
            logoContainerView.widthAnchor.constraint(equalToConstant: 40),
            logoContainerView.heightAnchor.constraint(equalToConstant: 40),

            logoImageView.centerXAnchor.constraint(equalTo: logoContainerView.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: logoContainerView.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 22),
            logoImageView.heightAnchor.constraint(equalToConstant: 22),

            appNameLabel.centerYAnchor.constraint(equalTo: logoContainerView.centerYAnchor),
            appNameLabel.leadingAnchor.constraint(equalTo: logoContainerView.trailingAnchor, constant: 8),

            welcomeLabel.topAnchor.constraint(equalTo: logoContainerView.bottomAnchor, constant: 28),
            welcomeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),

            subtitleLabel.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            emailTextField.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 28),
            emailTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            emailTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            emailTextField.heightAnchor.constraint(equalToConstant: 58),

            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 14),
            passwordTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            passwordTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            passwordTextField.heightAnchor.constraint(equalToConstant: 58),

            forgotPasswordButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 10),
            forgotPasswordButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            signInButton.topAnchor.constraint(equalTo: forgotPasswordButton.bottomAnchor, constant: 20),
            signInButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            signInButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            signInButton.heightAnchor.constraint(equalToConstant: 58),

            activityIndicator.centerXAnchor.constraint(equalTo: signInButton.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: signInButton.centerYAnchor),

            orLabel.topAnchor.constraint(equalTo: signInButton.bottomAnchor, constant: 24),
            orLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            leftDivider.centerYAnchor.constraint(equalTo: orLabel.centerYAnchor),
            leftDivider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            leftDivider.trailingAnchor.constraint(equalTo: orLabel.leadingAnchor, constant: -12),
            leftDivider.heightAnchor.constraint(equalToConstant: 1),

            rightDivider.centerYAnchor.constraint(equalTo: orLabel.centerYAnchor),
            rightDivider.leadingAnchor.constraint(equalTo: orLabel.trailingAnchor, constant: 12),
            rightDivider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            rightDivider.heightAnchor.constraint(equalToConstant: 1),

            appleButton.topAnchor.constraint(equalTo: orLabel.bottomAnchor, constant: 20),
            appleButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            appleButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            appleButton.heightAnchor.constraint(equalToConstant: 58),

            googleButton.topAnchor.constraint(equalTo: appleButton.bottomAnchor, constant: 12),
            googleButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            googleButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            googleButton.heightAnchor.constraint(equalToConstant: 58),

            createAccountButton.topAnchor.constraint(equalTo: googleButton.bottomAnchor, constant: 12),
            createAccountButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            createAccountButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            createAccountButton.heightAnchor.constraint(equalToConstant: 58),

            termsLabel.topAnchor.constraint(equalTo: createAccountButton.bottomAnchor, constant: 20),
            termsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            termsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            termsLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
        ])
    }

    private func setupActions() {
        signInButton.addTarget(self, action: #selector(signInTapped), for: .touchUpInside)
        forgotPasswordButton.addTarget(self, action: #selector(forgotPasswordTapped), for: .touchUpInside)
        appleButton.addTarget(self, action: #selector(appleSignInTapped), for: .touchUpInside)
        googleButton.addTarget(self, action: #selector(googleSignInTapped), for: .touchUpInside)
        createAccountButton.addTarget(self, action: #selector(createAccountTapped), for: .touchUpInside)
        let termsTap = UITapGestureRecognizer(target: self, action: #selector(termsLabelTapped(_:)))
        termsLabel.addGestureRecognizer(termsTap)
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    private func bindViewModel() {
        viewModel.onLoadingChanged = { [weak self] isLoading in
            DispatchQueue.main.async {
                isLoading ? self?.activityIndicator.startAnimating() : self?.activityIndicator.stopAnimating()
                self?.signInButton.isEnabled = !isLoading
                self?.signInButton.alpha = isLoading ? 0.6 : 1.0
            }
        }
        viewModel.onLoginSuccess = { [weak self] in
            DispatchQueue.main.async { self?.onLoginSuccess?() }
        }
        viewModel.onError = { [weak self] message in
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Xəta", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
            }
        }
    }

    @objc private func signInTapped() {
        viewModel.login(email: emailTextField.text, password: passwordTextField.text)
    }

    @objc private func forgotPasswordTapped() {
        onForgotPassword?()
    }

    @objc private func appleSignInTapped() {
        AuthService.shared.signInWithApple(presentingVC: self) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success: self?.onLoginSuccess?()
                case .failure(let error):
                    let alert = UIAlertController(title: "Xəta", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(alert, animated: true)
                }
            }
        }
    }

    @objc private func googleSignInTapped() {
        AuthManager.shared.signInWithGoogle(presentingVC: self) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success: self?.onLoginSuccess?()
                case .failure(let error):
                    let alert = UIAlertController(title: "Xəta", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(alert, animated: true)
                }
            }
        }
    }

    @objc private func createAccountTapped() {
        onCreateAccount?()
    }

    @objc private func termsLabelTapped(_ gesture: UITapGestureRecognizer) {
        guard let label = gesture.view as? UILabel,
              let text = label.attributedText?.string else { return }
        let point = gesture.location(in: label)
        if isTapped(in: label, at: point, range: (text as NSString).range(of: "Terms of Service")) {
            openURL("https://kolchiibrahim-sys.github.io/EchoShelf/terms")
        } else if isTapped(in: label, at: point, range: (text as NSString).range(of: "Privacy Policy")) {
            openURL("https://kolchiibrahim-sys.github.io/EchoShelf/privacy")
        }
    }

    @objc private func togglePasswordVisibility() {
        passwordTextField.isSecureTextEntry.toggle()
        if let eyeButton = passwordTextField.rightView as? UIButton {
            eyeButton.setImage(UIImage(systemName: passwordTextField.isSecureTextEntry ? "eye" : "eye.slash"), for: .normal)
        }
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func isTapped(in label: UILabel, at point: CGPoint, range: NSRange) -> Bool {
        guard let attributed = label.attributedText else { return false }
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: label.bounds.size)
        let textStorage = NSTextStorage(attributedString: attributed)
        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = label.numberOfLines
        textContainer.lineBreakMode = label.lineBreakMode
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        let index = layoutManager.characterIndex(for: point, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        return NSLocationInRange(index, range)
    }

    private func openURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
}

extension SignInViewController: @retroactive ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        view.window ?? UIWindow()
    }
}
