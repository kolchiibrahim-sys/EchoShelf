//
//  BookDetailViewController.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 22.02.26.
//
import UIKit

final class BookDetailViewController: UIViewController {

    private let book: Audiobook

    init(book: Audiobook) {
        self.book = book
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let backgroundView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(named: "AppBackground")
        return v
    }()

    private let backButton = DetailButton(systemName: "chevron.left")
    private let favButton  = DetailButton(systemName: "heart")

    private let coverView = UIView()
    private let coverIcon = UIImageView()

    private let titleLabel = UILabel()
    private let authorLabel = UILabel()
    private let statsLabel = UILabel()
    private let listenButton = GradientButton()

    private let descriptionTitle = DetailSectionTitle(text: "Description")
    private let descriptionLabel = DetailBodyLabel()
    private let chaptersTitle = DetailSectionTitle(text: "Preview Chapters")

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        configureData()
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    private func setupLayout() {

        view.addSubview(backgroundView)
        backgroundView.pinEdges(to: view)

        view.addSubview(scrollView)
        scrollView.pinEdges(to: view)
        scrollView.contentInsetAdjustmentBehavior = .never

        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])

        view.addSubview(backButton)
        view.addSubview(favButton)

        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            favButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            favButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])

        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)

        setupContent()
    }

    private func setupContent() {

        [coverView,titleLabel,authorLabel,statsLabel,
         listenButton,descriptionTitle,descriptionLabel,chaptersTitle]
            .forEach { contentView.addSubview($0) }

        coverView.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        coverView.layer.cornerRadius = 26
        coverView.translatesAutoresizingMaskIntoConstraints = false

        coverIcon.image = UIImage(systemName: "building.columns.fill")
        coverIcon.tintColor = .white
        coverIcon.translatesAutoresizingMaskIntoConstraints = false
        coverView.addSubview(coverIcon)

        titleLabel.font = .systemFont(ofSize: 26, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        authorLabel.textColor = UIColor(white: 1, alpha: 0.7)
        authorLabel.textAlignment = .center

        statsLabel.textColor = UIColor(white: 1, alpha: 0.6)
        statsLabel.font = .systemFont(ofSize: 14)
        statsLabel.textAlignment = .center

        listenButton.setTitle("▶ Listen Now", for: .normal)
        listenButton.addTarget(self, action: #selector(listenTapped), for: .touchUpInside)

        [titleLabel,authorLabel,statsLabel,listenButton,
         descriptionTitle,descriptionLabel,chaptersTitle]
            .forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        NSLayoutConstraint.activate([

            coverView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 70),
            coverView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            coverView.widthAnchor.constraint(equalToConstant: 240),
            coverView.heightAnchor.constraint(equalToConstant: 320),

            coverIcon.centerXAnchor.constraint(equalTo: coverView.centerXAnchor),
            coverIcon.centerYAnchor.constraint(equalTo: coverView.centerYAnchor),
            coverIcon.heightAnchor.constraint(equalToConstant: 50),
            coverIcon.widthAnchor.constraint(equalToConstant: 50),

            titleLabel.topAnchor.constraint(equalTo: coverView.bottomAnchor, constant: 26),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            authorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            authorLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            statsLabel.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 12),
            statsLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            listenButton.topAnchor.constraint(equalTo: statsLabel.bottomAnchor, constant: 26),
            listenButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            listenButton.widthAnchor.constraint(equalToConstant: 260),
            listenButton.heightAnchor.constraint(equalToConstant: 58),

            descriptionTitle.topAnchor.constraint(equalTo: listenButton.bottomAnchor, constant: 40),
            descriptionTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),

            descriptionLabel.topAnchor.constraint(equalTo: descriptionTitle.bottomAnchor, constant: 12),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            chaptersTitle.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 40),
            chaptersTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),

            chaptersTitle.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -140)
        ])
    }

    private func configureData() {
        titleLabel.text = book.title

        if let author = book.authors?.first {
            authorLabel.text = "\(author.firstName ?? "") \(author.lastName ?? "")"
        } else {
            authorLabel.text = "Unknown Author"
        }

        statsLabel.text = "⭐️ 4.8   •   Public Domain   •   LibriVox"

        descriptionLabel.text = book.description ?? "No description available."
    }

    @objc private func listenTapped() {
        NotificationCenter.default.post(name: .playerStarted, object: nil)
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
}
