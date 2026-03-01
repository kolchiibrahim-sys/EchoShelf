import UIKit
import Kingfisher

final class BookDetailViewController: UIViewController {

    private let viewModel: BookDetailViewModel

    init(book: Audiobook) {
        self.viewModel = BookDetailViewModel(book: book)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - UI

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // Header
    private let backButton   = DetailButton(systemName: "chevron.left")
    private let moreButton   = DetailButton(systemName: "ellipsis")
    private let headerLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "NOW PLAYING"
        lbl.font = .systemFont(ofSize: 13, weight: .semibold)
        lbl.textColor = UIColor.white.withAlphaComponent(0.6)
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    // Cover
    private let coverContainerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.5
        v.layer.shadowRadius = 24
        v.layer.shadowOffset = CGSize(width: 0, height: 12)
        return v
    }()
    private let coverImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 24
        iv.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    // Info
    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 26, weight: .bold)
        lbl.textColor = .white
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    private let authorLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 16, weight: .semibold)
        lbl.textColor = UIColor.systemPurple
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    // Stats
    private let statsView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    // Buttons
    private let downloadButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "arrow.down.circle"), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        btn.layer.cornerRadius = 28
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    private let listenButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .systemPurple
        config.baseForegroundColor = .white
        config.cornerStyle = .capsule
        config.image = UIImage(systemName: "play.fill")
        config.imagePlacement = .leading
        config.imagePadding = 8
        config.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 28, bottom: 16, trailing: 28)
        var title = AttributedString("Listen Now")
        title.font = .systemFont(ofSize: 16, weight: .bold)
        config.attributedTitle = title
        let btn = UIButton(configuration: config)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    private let favoriteButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "heart"), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        btn.layer.cornerRadius = 28
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // AI Summary
    private let aiSummaryContainer: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        v.layer.cornerRadius = 20
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    private let aiHeaderLabel: UILabel = {
        let lbl = UILabel()
        let attachment = NSTextAttachment()
        attachment.image = UIImage(systemName: "sparkles")?.withTintColor(.systemPurple)
        let attrStr = NSMutableAttributedString(attachment: attachment)
        attrStr.append(NSAttributedString(string: "  AI Summary Highlights",
            attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .bold), .foregroundColor: UIColor.white]))
        lbl.attributedText = attrStr
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    private let aiStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 14
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    // Description
    private let descriptionTitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Description"
        lbl.font = .systemFont(ofSize: 18, weight: .bold)
        lbl.textColor = .white
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    private let descriptionLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 14)
        lbl.textColor = UIColor.white.withAlphaComponent(0.7)
        lbl.numberOfLines = 4
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    private let readMoreButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Read more", for: .normal)
        btn.setTitleColor(UIColor.systemPurple, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private var isDescriptionExpanded = false

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "AppBackground")
        setupLayout()
        bindViewModel()
        viewModel.fetchDetail()
        configureData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
}

// MARK: - Binding

private extension BookDetailViewController {

    func bindViewModel() {
        viewModel.onDataUpdated = { [weak self] in
            self?.configureData()
        }
        viewModel.onError = { error in
            print("Detail error:", error)
        }
    }
}

// MARK: - Layout

private extension BookDetailViewController {

    func setupLayout() {
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.contentInsetAdjustmentBehavior = .never
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])

        setupHeader()
        setupCover()
        setupInfo()
        setupStats()
        setupButtons()
        setupAISummary()
        setupDescription()
    }

    func setupHeader() {
        view.addSubview(backButton)
        view.addSubview(moreButton)
        view.addSubview(headerLabel)

        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            moreButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            moreButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            headerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            headerLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor)
        ])

        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
    }

    func setupCover() {
        contentView.addSubview(coverContainerView)
        coverContainerView.addSubview(coverImageView)

        NSLayoutConstraint.activate([
            coverContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 100),
            coverContainerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            coverContainerView.widthAnchor.constraint(equalToConstant: 240),
            coverContainerView.heightAnchor.constraint(equalToConstant: 300),

            coverImageView.topAnchor.constraint(equalTo: coverContainerView.topAnchor),
            coverImageView.bottomAnchor.constraint(equalTo: coverContainerView.bottomAnchor),
            coverImageView.leadingAnchor.constraint(equalTo: coverContainerView.leadingAnchor),
            coverImageView.trailingAnchor.constraint(equalTo: coverContainerView.trailingAnchor)
        ])
    }

    func setupInfo() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(authorLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: coverContainerView.bottomAnchor, constant: 28),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            authorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            authorLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
    }

    func setupStats() {
        contentView.addSubview(statsView)

        let divider1 = makeDivider()
        let divider2 = makeDivider()

        let ratingItem  = makeStatItem(value: "4.8", label: "RATING",   icon: "star.fill",   iconColor: .systemYellow)
        let durationItem = makeStatItem(value: "—",  label: "DURATION", icon: "clock",        iconColor: .systemPurple)
        let languageItem = makeStatItem(value: "EN", label: "LANGUAGE", icon: "globe",        iconColor: .systemBlue)

        [ratingItem, divider1, durationItem, divider2, languageItem].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            statsView.addSubview($0)
        }

        NSLayoutConstraint.activate([
            statsView.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 28),
            statsView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            statsView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            statsView.heightAnchor.constraint(equalToConstant: 70),

            ratingItem.leadingAnchor.constraint(equalTo: statsView.leadingAnchor),
            ratingItem.centerYAnchor.constraint(equalTo: statsView.centerYAnchor),

            divider1.centerXAnchor.constraint(equalTo: statsView.centerXAnchor, constant: -statsView.bounds.width / 3),
            divider1.centerYAnchor.constraint(equalTo: statsView.centerYAnchor),
            divider1.widthAnchor.constraint(equalToConstant: 1),
            divider1.heightAnchor.constraint(equalToConstant: 36),

            durationItem.centerXAnchor.constraint(equalTo: statsView.centerXAnchor),
            durationItem.centerYAnchor.constraint(equalTo: statsView.centerYAnchor),

            divider2.centerXAnchor.constraint(equalTo: statsView.centerXAnchor, constant: statsView.bounds.width / 3),
            divider2.centerYAnchor.constraint(equalTo: statsView.centerYAnchor),
            divider2.widthAnchor.constraint(equalToConstant: 1),
            divider2.heightAnchor.constraint(equalToConstant: 36),

            languageItem.trailingAnchor.constraint(equalTo: statsView.trailingAnchor),
            languageItem.centerYAnchor.constraint(equalTo: statsView.centerYAnchor)
        ])
    }

    func setupButtons() {
        contentView.addSubview(downloadButton)
        contentView.addSubview(listenButton)
        contentView.addSubview(favoriteButton)

        NSLayoutConstraint.activate([
            listenButton.topAnchor.constraint(equalTo: statsView.bottomAnchor, constant: 28),
            listenButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            downloadButton.centerYAnchor.constraint(equalTo: listenButton.centerYAnchor),
            downloadButton.trailingAnchor.constraint(equalTo: listenButton.leadingAnchor, constant: -16),
            downloadButton.widthAnchor.constraint(equalToConstant: 56),
            downloadButton.heightAnchor.constraint(equalToConstant: 56),

            favoriteButton.centerYAnchor.constraint(equalTo: listenButton.centerYAnchor),
            favoriteButton.leadingAnchor.constraint(equalTo: listenButton.trailingAnchor, constant: 16),
            favoriteButton.widthAnchor.constraint(equalToConstant: 56),
            favoriteButton.heightAnchor.constraint(equalToConstant: 56)
        ])

        listenButton.addTarget(self, action: #selector(listenTapped), for: .touchUpInside)
        favoriteButton.addTarget(self, action: #selector(favTapped), for: .touchUpInside)
    }

    func setupAISummary() {
        contentView.addSubview(aiSummaryContainer)
        aiSummaryContainer.addSubview(aiHeaderLabel)
        aiSummaryContainer.addSubview(aiStackView)

        NSLayoutConstraint.activate([
            aiSummaryContainer.topAnchor.constraint(equalTo: listenButton.bottomAnchor, constant: 36),
            aiSummaryContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            aiSummaryContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            aiHeaderLabel.topAnchor.constraint(equalTo: aiSummaryContainer.topAnchor, constant: 18),
            aiHeaderLabel.leadingAnchor.constraint(equalTo: aiSummaryContainer.leadingAnchor, constant: 18),

            aiStackView.topAnchor.constraint(equalTo: aiHeaderLabel.bottomAnchor, constant: 16),
            aiStackView.leadingAnchor.constraint(equalTo: aiSummaryContainer.leadingAnchor, constant: 18),
            aiStackView.trailingAnchor.constraint(equalTo: aiSummaryContainer.trailingAnchor, constant: -18),
            aiStackView.bottomAnchor.constraint(equalTo: aiSummaryContainer.bottomAnchor, constant: -18)
        ])
    }

    func setupDescription() {
        contentView.addSubview(descriptionTitleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(readMoreButton)

        NSLayoutConstraint.activate([
            descriptionTitleLabel.topAnchor.constraint(equalTo: aiSummaryContainer.bottomAnchor, constant: 32),
            descriptionTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),

            descriptionLabel.topAnchor.constraint(equalTo: descriptionTitleLabel.bottomAnchor, constant: 12),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            readMoreButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 6),
            readMoreButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            readMoreButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -60)
        ])

        readMoreButton.addTarget(self, action: #selector(readMoreTapped), for: .touchUpInside)
    }
}

// MARK: - Configure Data

private extension BookDetailViewController {

    func configureData() {
        let book = viewModel.book

        titleLabel.text = book.title
        authorLabel.text = book.authorName
        descriptionLabel.text = book.description?.htmlStripped ?? "No description available."

        if let url = book.coverURL {
            coverImageView.kf.setImage(with: url)
        }

        // Duration
        if let sections = book.numSections?.value {
            updateStatValue(in: statsView, label: "DURATION", value: "\(sections)h 30m")
        }

        // AI Summary
        buildAISummary(viewModel.aiSummary)
    }

    func buildAISummary(_ points: [String]) {
        aiStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for (index, point) in points.enumerated() {
            let row = makeAISummaryRow(number: index + 1, text: point)
            aiStackView.addArrangedSubview(row)
        }
    }

    func makeAISummaryRow(number: Int, text: String) -> UIView {
        let numberLabel = UILabel()
        numberLabel.text = String(format: "%02d", number)
        numberLabel.font = .systemFont(ofSize: 13, weight: .bold)
        numberLabel.textColor = UIColor.systemPurple
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        numberLabel.setContentHuggingPriority(.required, for: .horizontal)

        let textLabel = UILabel()
        textLabel.text = text
        textLabel.font = .systemFont(ofSize: 14)
        textLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        textLabel.numberOfLines = 0
        textLabel.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView(arrangedSubviews: [numberLabel, textLabel])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .top
        return stack
    }

    func updateStatValue(in container: UIView, label: String, value: String) {
        // stat item-ləri tap edib value-ni yenilə
        for sub in container.subviews {
            if let stack = sub as? UIStackView {
                for arranged in stack.arrangedSubviews {
                    if let lbl = arranged as? UILabel, lbl.text == label {
                        if let valueLabel = stack.arrangedSubviews.first as? UILabel {
                            valueLabel.text = value
                        }
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    func makeStatItem(value: String, label: String, icon: String, iconColor: UIColor) -> UIStackView {
        let iconImage = UIImageView(image: UIImage(systemName: icon))
        iconImage.tintColor = iconColor
        iconImage.contentMode = .scaleAspectFit
        iconImage.translatesAutoresizingMaskIntoConstraints = false
        iconImage.widthAnchor.constraint(equalToConstant: 20).isActive = true
        iconImage.heightAnchor.constraint(equalToConstant: 20).isActive = true

        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 17, weight: .bold)
        valueLabel.textColor = .white
        valueLabel.textAlignment = .center

        let titleLabel = UILabel()
        titleLabel.text = label
        titleLabel.font = .systemFont(ofSize: 10, weight: .medium)
        titleLabel.textColor = UIColor.white.withAlphaComponent(0.4)
        titleLabel.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [iconImage, valueLabel, titleLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 4
        return stack
    }

    func makeDivider() -> UIView {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        return v
    }
}

// MARK: - Actions

private extension BookDetailViewController {

    @objc func listenTapped() {
        PlayerManager.shared.play(book: viewModel.book)
        let playerVC = PlayerViewController()
        playerVC.modalPresentationStyle = .fullScreen
        present(playerVC, animated: true)
    }

    @objc func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc func favTapped() {
        let isFav = favoriteButton.tintColor == UIColor.systemPink
        favoriteButton.tintColor = isFav ? .white : .systemPink
        favoriteButton.setImage(
            UIImage(systemName: isFav ? "heart" : "heart.fill"), for: .normal
        )
    }

    @objc func readMoreTapped() {
        isDescriptionExpanded.toggle()
        descriptionLabel.numberOfLines = isDescriptionExpanded ? 0 : 4
        readMoreButton.setTitle(isDescriptionExpanded ? "Show less" : "Read more", for: .normal)
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - String Extension

private extension String {
    var htmlStripped: String {
        guard let data = data(using: .utf8),
              let attributed = try? NSAttributedString(
                data: data,
                options: [.documentType: NSAttributedString.DocumentType.html,
                          .characterEncoding: String.Encoding.utf8.rawValue],
                documentAttributes: nil)
        else { return self }
        return attributed.string
    }
}
