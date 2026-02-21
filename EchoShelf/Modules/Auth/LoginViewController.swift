//
//  LoginViewController.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 21.02.26.
//
import UIKit

final class LoginViewController: UIViewController {

    var onLoginSuccess: (() -> Void)?
    private let viewModel = LoginViewModel()

    private let backgroundImage: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "LoginBG"))
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let cardView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(white: 0.06, alpha: 0.85)
        v.layer.cornerRadius = 36
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let logoImage: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "EchoLogo"))
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let appNameLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "EchoShelf"
        lbl.textColor = .white
        lbl.font = .systemFont(ofSize: 18, weight: .semibold)
        return lbl
    }()

    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Welcome Back"
        lbl.textColor = .white
        lbl.font = .systemFont(ofSize: 32, weight: .bold)
        return lbl
    }()

    private let subtitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Sign in to continue your listening journey."
        lbl.textColor = UIColor(white: 1, alpha: 0.7)
        lbl.font = .systemFont(ofSize: 14)
        return lbl
    }()

    private let emailField = UITextField()
    private let passwordField = UITextField()

    private let forgotButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Forgot Password?", for: .normal)
        btn.setTitleColor(UIColor(white: 1, alpha: 0.6), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 12)
        return btn
    }()

    private let signInButton = UIButton(type: .system)
    private let appleButton = UIButton(type: .system)
    private let googleButton = UIButton(type: .system)
    private let createAccountButton = UIButton(type: .system)

    private let signInGradient = CAGradientLayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupFields()
        setupButtons()
        setupLayout()

        signInButton.addTarget(self, action: #selector(signInTapped), for: .touchUpInside)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        signInGradient.frame = signInButton.bounds
    }

    private func setupFields() {
        [emailField, passwordField].forEach {
            $0.backgroundColor = UIColor(white: 1, alpha: 0.08)
            $0.textColor = .white
            $0.layer.cornerRadius = 18
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.heightAnchor.constraint(equalToConstant: 56).isActive = true

            let padding = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 56))
            $0.leftView = padding
            $0.leftViewMode = .always
        }

        emailField.placeholder = "Email Address"
        passwordField.placeholder = "Password"
        passwordField.isSecureTextEntry = true
    }

    private func makeIcon(named: String) -> UIImageView {
        let iv = UIImageView(image: UIImage(named: named))
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.widthAnchor.constraint(equalToConstant: 20).isActive = true
        iv.heightAnchor.constraint(equalToConstant: 20).isActive = true
        return iv
    }

    private func makeLabel(_ text: String, _ color: UIColor) -> UILabel {
        let lbl = UILabel()
        lbl.text = text
        lbl.textColor = color
        lbl.font = .systemFont(ofSize: 14, weight: .semibold)
        return lbl
    }

    private func setupButtons() {

        signInButton.setTitle("Sign In", for: .normal)
        signInButton.setTitleColor(.white, for: .normal)
        signInButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        signInButton.layer.cornerRadius = 28
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        signInButton.heightAnchor.constraint(equalToConstant: 56).isActive = true
        signInButton.clipsToBounds = true

        signInGradient.colors = [
            UIColor(red: 0.55, green: 0.40, blue: 1.0, alpha: 1).cgColor,
            UIColor(red: 0.35, green: 0.55, blue: 1.0, alpha: 1).cgColor
        ]
        signInGradient.cornerRadius = 28
        signInButton.layer.insertSublayer(signInGradient, at: 0)

        let appleStack = UIStackView(arrangedSubviews: [makeIcon(named: "Apple"), makeLabel("Continue with Apple", .white)])
        appleStack.spacing = 10
        appleStack.alignment = .center

        appleButton.backgroundColor = .black
        appleButton.layer.cornerRadius = 28
        appleButton.translatesAutoresizingMaskIntoConstraints = false
        appleButton.heightAnchor.constraint(equalToConstant: 56).isActive = true
        appleButton.addSubview(appleStack)
        appleStack.translatesAutoresizingMaskIntoConstraints = false
        appleStack.centerXAnchor.constraint(equalTo: appleButton.centerXAnchor).isActive = true
        appleStack.centerYAnchor.constraint(equalTo: appleButton.centerYAnchor).isActive = true

        let googleStack = UIStackView(arrangedSubviews: [makeIcon(named: "Google"), makeLabel("Continue with Google", .black)])
        googleStack.spacing = 10
        googleStack.alignment = .center

        googleButton.backgroundColor = .white
        googleButton.layer.cornerRadius = 28
        googleButton.translatesAutoresizingMaskIntoConstraints = false
        googleButton.heightAnchor.constraint(equalToConstant: 56).isActive = true
        googleButton.addSubview(googleStack)
        googleStack.translatesAutoresizingMaskIntoConstraints = false
        googleStack.centerXAnchor.constraint(equalTo: googleButton.centerXAnchor).isActive = true
        googleStack.centerYAnchor.constraint(equalTo: googleButton.centerYAnchor).isActive = true

        createAccountButton.setTitle("Create Account", for: .normal)
        createAccountButton.setTitleColor(.white, for: .normal)
        createAccountButton.layer.cornerRadius = 28
        createAccountButton.layer.borderWidth = 1
        createAccountButton.layer.borderColor = UIColor(white: 1, alpha: 0.4).cgColor
        createAccountButton.translatesAutoresizingMaskIntoConstraints = false
        createAccountButton.heightAnchor.constraint(equalToConstant: 56).isActive = true
    }

    private func setupLayout() {

        let headerStack = UIStackView(arrangedSubviews: [logoImage, appNameLabel])
        headerStack.spacing = 8
        headerStack.alignment = .center

        let mainStack = UIStackView(arrangedSubviews: [
            headerStack,
            titleLabel,
            subtitleLabel,
            emailField,
            passwordField,
            forgotButton,
            signInButton,
            appleButton,
            googleButton,
            createAccountButton
        ])

        mainStack.axis = .vertical
        mainStack.spacing = 20
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(backgroundImage)
        view.addSubview(cardView)
        cardView.addSubview(mainStack)

        NSLayoutConstraint.activate([
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            cardView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            mainStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            mainStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24),
            mainStack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 32),
            mainStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -32),

            logoImage.heightAnchor.constraint(equalToConstant: 28)
        ])
    }

    @objc private func signInTapped() {
        onLoginSuccess?()
    }
}
