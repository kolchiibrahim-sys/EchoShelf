import UIKit
import Kingfisher

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
    private let coverImageView = UIImageView()

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

        coverImageView.contentMode = .scaleAspectFill
        coverImageView.clipsToBounds = true
        coverImageView.layer.cornerRadius = 26
        coverImageView.translatesAutoresizingMaskIntoConstraints = false
        coverView.addSubview(coverImageView)

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

            coverImageView.topAnchor.constraint(equalTo: coverView.topAnchor),
            coverImageView.bottomAnchor.constraint(equalTo: coverView.bottomAnchor),
            coverImageView.leadingAnchor.constraint(equalTo: coverView.leadingAnchor),
            coverImageView.trailingAnchor.constraint(equalTo: coverView.trailingAnchor),

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
        authorLabel.text = book.authorName
        statsLabel.text = "Public Domain • LibriVox"
        descriptionLabel.text = book.description ?? "No description available."

        if let url = book.coverURL {
            coverImageView.kf.setImage(with: url)
        } else {
            coverImageView.image = UIImage(systemName: "book.fill")
        }
    }

    @objc private func listenTapped() {
        PlayerManager.shared.play(book: book)
        let playerVC = PlayerViewController()
        playerVC.modalPresentationStyle = .fullScreen
        present(playerVC, animated: true)
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
}
