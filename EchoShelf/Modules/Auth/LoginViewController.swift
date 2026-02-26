//
//  LoginViewController.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 21.02.26.
//
import UIKit

class SignInViewController: UIViewController {

    // MARK: - Callbacks
    var onLoginSuccess: (() -> Void)?
    var onCreateAccount: (() -> Void)?
    var onForgotPassword: (() -> Void)?

    // MARK: - UI Elements

    private let backButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("<", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 22, weight: .medium)
        btn.setTitleColor(.white, for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

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

    private let welcomeLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Welcome Back"
        lbl.font = .systemFont(ofSize: 34, weight: .bold)
        lbl.textColor = .white
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let subtitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Sign in to continue your listening journey."
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

        // Left icon
        let icon = UIImageView(image: UIImage(systemName: "envelope"))
        icon.tintColor = UIColor.white.withAlphaComponent(0.5)
        icon.frame = CGRect(x: 0, y: 0, width: 44, height: 24)
        icon.contentMode = .center
        tf.leftView = icon

        return tf
    }()

    private let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(
            string: "Password",
            attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.5)]
        )
        tf.textColor = .white
        tf.backgroundColor = UIColor(red: 0.16, green: 0.17, blue: 0.24, alpha: 1.0)
        tf.layer.cornerRadius = 16
        tf.isSecureTextEntry = true
        tf.leftViewMode = .always
        tf.rightViewMode = .always
        tf.translatesAutoresizingMaskIntoConstraints = false

        // Left icon
        let lockIcon = UIImageView(image: UIImage(systemName: "lock"))
        lockIcon.tintColor = UIColor.white.withAlphaComponent(0.5)
        lockIcon.frame = CGRect(x: 0, y: 0, width: 44, height: 24)
        lockIcon.contentMode = .center
        tf.leftView = lockIcon

        // Right eye icon
        let eyeButton = UIButton(type: .system)
        eyeButton.setImage(UIImage(systemName: "eye"), for: .normal)
        eyeButton.tintColor = UIColor.white.withAlphaComponent(0.5)
        eyeButton.frame = CGRect(x: 0, y: 0, width: 44, height: 24)
        eyeButton.addTarget(nil, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        tf.rightView = eyeButton

        return tf
    }()

    private let forgotPasswordButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Forgot Password?", for: .normal)
        btn.setTitleColor(UIColor.white.withAlphaComponent(0.7), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let signInButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Sign In →", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        btn.backgroundColor = UIColor(red: 0.42, green: 0.38, blue: 0.93, alpha: 1.0)
        btn.layer.cornerRadius = 28
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let orLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "OR"
        lbl.font = .systemFont(ofSize: 13, weight: .medium)
        lbl.textColor = UIColor.white.withAlphaComponent(0.4)
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let leftDivider: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let rightDivider: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let appleButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("  Continue with Apple", for: .normal)
        btn.setImage(UIImage(systemName: "apple.logo"), for: .normal)
        btn.tintColor = .white
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        btn.backgroundColor = .black
        btn.layer.cornerRadius = 28
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let googleButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("  Continue with Google", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 28
        btn.translatesAutoresizingMaskIntoConstraints = false

        // Google "G" label as a simple colored text placeholder
        // In production, use the actual Google logo asset
        let gLabel = UILabel()
        gLabel.text = "G"
        gLabel.font = .systemFont(ofSize: 18, weight: .bold)
        gLabel.textColor = UIColor(red: 0.26, green: 0.52, blue: 0.96, alpha: 1)
        gLabel.translatesAutoresizingMaskIntoConstraints = false
        btn.addSubview(gLabel)
        NSLayoutConstraint.activate([
            gLabel.leadingAnchor.constraint(equalTo: btn.leadingAnchor, constant: 24),
            gLabel.centerYAnchor.constraint(equalTo: btn.centerYAnchor)
        ])

        return btn
    }()

    private let createAccountButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Create Account", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        btn.backgroundColor = .clear
        btn.layer.cornerRadius = 28
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.white.withAlphaComponent(0.25).cgColor
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let termsLabel: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 0
        lbl.textAlignment = .center
        let fullText = "By signing in, you agree to our Terms of Service and\nPrivacy Policy."
        let attributed = NSMutableAttributedString(
            string: fullText,
            attributes: [
                .font: UIFont.systemFont(ofSize: 13),
                .foregroundColor: UIColor.white.withAlphaComponent(0.5)
            ]
        )
        let purple = UIColor(red: 0.42, green: 0.38, blue: 0.93, alpha: 1.0)
        if let tosRange = fullText.range(of: "Terms of Service") {
            attributed.addAttribute(.foregroundColor, value: purple, range: NSRange(tosRange, in: fullText))
        }
        if let ppRange = fullText.range(of: "Privacy Policy") {
            attributed.addAttribute(.foregroundColor, value: purple, range: NSRange(ppRange, in: fullText))
        }
        lbl.attributedText = attributed
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.09, green: 0.10, blue: 0.16, alpha: 1.0)

        // Add subviews
        view.addSubview(backButton)
        view.addSubview(logoContainerView)
        logoContainerView.addSubview(logoImageView)
        view.addSubview(appNameLabel)
        view.addSubview(welcomeLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(forgotPasswordButton)
        view.addSubview(signInButton)
        view.addSubview(leftDivider)
        view.addSubview(orLabel)
        view.addSubview(rightDivider)
        view.addSubview(appleButton)
        view.addSubview(googleButton)
        view.addSubview(createAccountButton)
        view.addSubview(termsLabel)

        NSLayoutConstraint.activate([
            // Back button
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

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

            // Welcome label
            welcomeLabel.topAnchor.constraint(equalTo: logoContainerView.bottomAnchor, constant: 32),
            welcomeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),

            // Subtitle
            subtitleLabel.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            // Email field
            emailTextField.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 28),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            emailTextField.heightAnchor.constraint(equalToConstant: 58),

            // Password field
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 14),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            passwordTextField.heightAnchor.constraint(equalToConstant: 58),

            // Forgot password
            forgotPasswordButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 10),
            forgotPasswordButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            // Sign In button
            signInButton.topAnchor.constraint(equalTo: forgotPasswordButton.bottomAnchor, constant: 20),
            signInButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            signInButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            signInButton.heightAnchor.constraint(equalToConstant: 58),

            // Dividers & OR
            leftDivider.centerYAnchor.constraint(equalTo: orLabel.centerYAnchor),
            leftDivider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            leftDivider.trailingAnchor.constraint(equalTo: orLabel.leadingAnchor, constant: -12),
            leftDivider.heightAnchor.constraint(equalToConstant: 1),

            orLabel.topAnchor.constraint(equalTo: signInButton.bottomAnchor, constant: 24),
            orLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            rightDivider.centerYAnchor.constraint(equalTo: orLabel.centerYAnchor),
            rightDivider.leadingAnchor.constraint(equalTo: orLabel.trailingAnchor, constant: 12),
            rightDivider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            rightDivider.heightAnchor.constraint(equalToConstant: 1),

            // Apple button
            appleButton.topAnchor.constraint(equalTo: orLabel.bottomAnchor, constant: 20),
            appleButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            appleButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            appleButton.heightAnchor.constraint(equalToConstant: 58),

            // Google button
            googleButton.topAnchor.constraint(equalTo: appleButton.bottomAnchor, constant: 14),
            googleButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            googleButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            googleButton.heightAnchor.constraint(equalToConstant: 58),

            // Create Account button
            createAccountButton.topAnchor.constraint(equalTo: googleButton.bottomAnchor, constant: 14),
            createAccountButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            createAccountButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            createAccountButton.heightAnchor.constraint(equalToConstant: 58),

            // Terms label
            termsLabel.topAnchor.constraint(equalTo: createAccountButton.bottomAnchor, constant: 20),
            termsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            termsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            termsLabel.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }

    private func setupActions() {
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        signInButton.addTarget(self, action: #selector(signInTapped), for: .touchUpInside)
        forgotPasswordButton.addTarget(self, action: #selector(forgotPasswordTapped), for: .touchUpInside)
        appleButton.addTarget(self, action: #selector(appleSignInTapped), for: .touchUpInside)
        googleButton.addTarget(self, action: #selector(googleSignInTapped), for: .touchUpInside)
        createAccountButton.addTarget(self, action: #selector(createAccountTapped), for: .touchUpInside)

        // Dismiss keyboard on tap
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    // MARK: - Actions

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func signInTapped() {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            // Show validation alert
            let alert = UIAlertController(title: "Missing Fields", message: "Please fill in all fields.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        // TODO: Replace with real auth service call
        // Simulating successful login — replace with your API/Firebase/etc.
        onLoginSuccess?()
    }

    @objc private func forgotPasswordTapped() {
        onForgotPassword?()
    }

    @objc private func appleSignInTapped() {
        // TODO: Implement Apple Sign In (ASAuthorizationAppleIDProvider)
        print("Apple sign in tapped")
    }

    @objc private func googleSignInTapped() {
        // TODO: Implement Google Sign In (GoogleSignIn SDK)
        print("Google sign in tapped")
    }

    @objc private func createAccountTapped() {
        onCreateAccount?()
    }

    @objc private func togglePasswordVisibility() {
        passwordTextField.isSecureTextEntry.toggle()
        if let eyeButton = passwordTextField.rightView as? UIButton {
            let iconName = passwordTextField.isSecureTextEntry ? "eye" : "eye.slash"
            eyeButton.setImage(UIImage(systemName: iconName), for: .normal)
        }
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
