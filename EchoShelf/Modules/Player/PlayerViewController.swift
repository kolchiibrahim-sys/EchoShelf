//
//  PlayerViewController.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 24.02.26.
//
import UIKit

final class PlayerViewController: UIViewController {

    private let book = PlayerManager.shared.currentBook

    private let gradientLayer = CAGradientLayer()

    private let coverView = UIView()
    private let coverIcon = UIImageView()

    private let titleLabel = UILabel()
    private let authorLabel = UILabel()
    private let progressSlider = UISlider()
    private let currentTimeLabel = UILabel()
    private let durationLabel = UILabel()

    private let playButton = UIButton(type: .system)
    private let closeButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradient()
        setupUI()
        configureData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    private func setupGradient() {
        gradientLayer.colors = [
            UIColor(red: 20/255, green: 18/255, blue: 60/255, alpha: 1).cgColor,
            UIColor(red: 10/255, green: 10/255, blue: 35/255, alpha: 1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func setupUI() {

        coverView.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        coverView.layer.cornerRadius = 24
        coverView.translatesAutoresizingMaskIntoConstraints = false

        coverIcon.image = UIImage(systemName: "building.columns.fill")
        coverIcon.tintColor = .white
        coverIcon.translatesAutoresizingMaskIntoConstraints = false
        coverView.addSubview(coverIcon)

        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        authorLabel.font = .systemFont(ofSize: 16)
        authorLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        authorLabel.textAlignment = .center
        authorLabel.translatesAutoresizingMaskIntoConstraints = false

        progressSlider.minimumTrackTintColor = .systemPurple
        progressSlider.maximumTrackTintColor = UIColor.white.withAlphaComponent(0.2)
        progressSlider.translatesAutoresizingMaskIntoConstraints = false

        currentTimeLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        currentTimeLabel.font = .systemFont(ofSize: 13)
        currentTimeLabel.translatesAutoresizingMaskIntoConstraints = false

        durationLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        durationLabel.font = .systemFont(ofSize: 13)
        durationLabel.translatesAutoresizingMaskIntoConstraints = false

        playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        playButton.tintColor = .white
        playButton.backgroundColor = .systemPurple
        playButton.layer.cornerRadius = 35
        playButton.translatesAutoresizingMaskIntoConstraints = false

        closeButton.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        closeButton.tintColor = .white
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)

        view.addSubview(closeButton)
        view.addSubview(coverView)
        view.addSubview(titleLabel)
        view.addSubview(authorLabel)
        view.addSubview(progressSlider)
        view.addSubview(currentTimeLabel)
        view.addSubview(durationLabel)
        view.addSubview(playButton)

        NSLayoutConstraint.activate([

            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            coverView.topAnchor.constraint(equalTo: view.topAnchor, constant: 120),
            coverView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            coverView.widthAnchor.constraint(equalToConstant: 260),
            coverView.heightAnchor.constraint(equalToConstant: 340),

            coverIcon.centerXAnchor.constraint(equalTo: coverView.centerXAnchor),
            coverIcon.centerYAnchor.constraint(equalTo: coverView.centerYAnchor),
            coverIcon.heightAnchor.constraint(equalToConstant: 50),
            coverIcon.widthAnchor.constraint(equalToConstant: 50),

            titleLabel.topAnchor.constraint(equalTo: coverView.bottomAnchor, constant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),

            authorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            authorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            progressSlider.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 40),
            progressSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            progressSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),

            currentTimeLabel.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: 4),
            currentTimeLabel.leadingAnchor.constraint(equalTo: progressSlider.leadingAnchor),

            durationLabel.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: 4),
            durationLabel.trailingAnchor.constraint(equalTo: progressSlider.trailingAnchor),

            playButton.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: 50),
            playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playButton.widthAnchor.constraint(equalToConstant: 70),
            playButton.heightAnchor.constraint(equalToConstant: 70)
        ])
    }

    private func configureData() {
        guard let book else { return }

        titleLabel.text = book.title

        if let author = book.authors?.first {
            authorLabel.text = "\(author.firstName ?? "") \(author.lastName ?? "")"
        } else {
            authorLabel.text = "Unknown Author"
        }

        currentTimeLabel.text = "0:47"
        durationLabel.text = "12:30"
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }
}
