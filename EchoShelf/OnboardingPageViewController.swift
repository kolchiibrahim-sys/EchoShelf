//
//  OnboardingPageViewController.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 14.03.26.
//
import UIKit

final class OnboardingPageViewController: UIViewController {

    private let page: OnboardingPage

    init(page: OnboardingPage) {
        self.page = page
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    private lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let gradientOverlay: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let badgeLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 11, weight: .bold)
        lbl.textColor = UIColor(named: "PrimaryGradientStart")
        lbl.backgroundColor = UIColor(named: "PrimaryGradientStart")?.withAlphaComponent(0.15)
        lbl.layer.cornerRadius = 10
        lbl.clipsToBounds = true
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 32, weight: .bold)
        lbl.textColor = .white
        lbl.numberOfLines = 0
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let subtitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 16, weight: .regular)
        lbl.textColor = UIColor(named: "OnboardingSubtitle") ?? UIColor.white.withAlphaComponent(0.6)
        lbl.numberOfLines = 0
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private lazy var primaryButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.baseForegroundColor = .white
        config.baseBackgroundColor = UIColor(named: "PrimaryGradientStart")
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attrs in
            var a = attrs
            a.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            return a
        }
        config.cornerStyle = .capsule
        let btn = UIButton(configuration: config)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private lazy var secondaryButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.baseForegroundColor = UIColor.white.withAlphaComponent(0.6)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attrs in
            var a = attrs
            a.font = UIFont.systemFont(ofSize: 15, weight: .medium)
            return a
        }
        let btn = UIButton(configuration: config)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    var onPrimaryTapped: (() -> Void)?
    var onSecondaryTapped: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        configure()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyGradient()
    }

    private func setupUI() {
        view.backgroundColor = UIColor(named: "AppBackground")

        view.addSubview(imageView)
        view.addSubview(gradientOverlay)
        view.addSubview(badgeLabel)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(primaryButton)
        view.addSubview(secondaryButton)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.55),

            gradientOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            gradientOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gradientOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            gradientOverlay.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.65),

            secondaryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            secondaryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            secondaryButton.heightAnchor.constraint(equalToConstant: 44),

            primaryButton.bottomAnchor.constraint(equalTo: secondaryButton.topAnchor, constant: -8),
            primaryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            primaryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            primaryButton.heightAnchor.constraint(equalToConstant: 58),

            subtitleLabel.bottomAnchor.constraint(equalTo: primaryButton.topAnchor, constant: -24),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            titleLabel.bottomAnchor.constraint(equalTo: subtitleLabel.topAnchor, constant: -12),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            badgeLabel.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -12),
            badgeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            badgeLabel.heightAnchor.constraint(equalToConstant: 24),
            badgeLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 80)
        ])
    }

    private func setupActions() {
        primaryButton.addTarget(self, action: #selector(primaryTapped), for: .touchUpInside)
        secondaryButton.addTarget(self, action: #selector(secondaryTapped), for: .touchUpInside)
    }

    private func configure() {
        imageView.image = UIImage(named: page.imageName)

        if let badge = page.badge {
            badgeLabel.text = "  \(badge)  "
            badgeLabel.isHidden = false
        } else {
            badgeLabel.isHidden = true
        }

        if let highlighted = page.highlightedWord {
            titleLabel.attributedText = buildHighlightedTitle(
                full: page.title,
                highlighted: highlighted
            )
        } else {
            titleLabel.text = page.title
        }

        subtitleLabel.text = page.subtitle

        var primaryConfig = primaryButton.configuration
        primaryConfig?.title = page.primaryButtonTitle
        primaryButton.configuration = primaryConfig

        if let secondary = page.secondaryButtonTitle {
            var secondaryConfig = secondaryButton.configuration
            secondaryConfig?.title = secondary
            secondaryButton.configuration = secondaryConfig
            secondaryButton.isHidden = false
        } else {
            secondaryButton.isHidden = true
        }
    }

    private func applyGradient() {
        gradientOverlay.layer.sublayers?.removeAll()
        let gradient = CAGradientLayer()
        gradient.frame = gradientOverlay.bounds
        gradient.colors = [
            UIColor.clear.cgColor,
            UIColor(named: "AppBackground")?.cgColor ?? UIColor.black.cgColor
        ]
        gradient.locations = [0.3, 1.0]
        gradientOverlay.layer.addSublayer(gradient)
    }

    private func buildHighlightedTitle(full: String, highlighted: String) -> NSAttributedString {
        let attributed = NSMutableAttributedString(
            string: full,
            attributes: [
                .font: UIFont.systemFont(ofSize: 32, weight: .bold),
                .foregroundColor: UIColor.white
            ]
        )
        let purple = UIColor(named: "PrimaryGradientStart") ?? .systemPurple
        if let range = full.range(of: highlighted) {
            attributed.addAttributes([
                .foregroundColor: purple,
                .font: UIFont.italicSystemFont(ofSize: 32)
            ], range: NSRange(range, in: full))
        }
        return attributed
    }

    @objc private func primaryTapped() {
        onPrimaryTapped?()
    }

    @objc private func secondaryTapped() {
        onSecondaryTapped?()
    }
}
