//
//  BookDetailViewController.swift
//  EchoShelf
//
import UIKit
import Kingfisher

enum BookDetailType {
    case audiobook(Audiobook)
    case ebook(Ebook)
}

final class BookDetailViewController: UIViewController {

    private let viewModel: BookDetailViewModel
    private let bookType: BookDetailType
    private var ebookDetailVM: EbookDetailViewModel?

    init(book: Audiobook) {
        self.bookType = .audiobook(book)
        self.viewModel = BookDetailViewModel(book: book)
        super.init(nibName: nil, bundle: nil)
    }

    init(ebook: Ebook) {
        self.bookType = .ebook(ebook)
        self.viewModel = BookDetailViewModel(book: Audiobook(
            id: FlexibleInt(from: 0),
            title: ebook.title,
            description: nil,
            urlLibrivox: nil,
            urlRss: nil,
            urlZipFile: nil,
            numSections: nil,
            authors: [Author(firstName: ebook.authorName, lastName: nil)],
            coverURL: ebook.coverURL
        ))
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.contentInsetAdjustmentBehavior = .never
        sv.showsVerticalScrollIndicator = false
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private lazy var contentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private lazy var backButton: UIButton = {
        let btn = DetailButton(systemName: "chevron.left")
        return btn
    }()

    private lazy var moreButton: UIButton = {
        let btn = DetailButton(systemName: "ellipsis")
        return btn
    }()

    private lazy var headerLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "NOW PLAYING"
        lbl.font = .systemFont(ofSize: 13, weight: .semibold)
        lbl.textColor = UIColor(named: "OnDarkTextSecondary")
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private lazy var coverContainerView: UIView = {
        let v = UIView()
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.5
        v.layer.shadowRadius = 24
        v.layer.shadowOffset = CGSize(width: 0, height: 12)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private lazy var coverImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 24
        iv.backgroundColor = UIColor(named: "FillGlassMedium")
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private lazy var titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 26, weight: .bold)
        lbl.textColor = UIColor(named: "OnDarkTextPrimary")
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private lazy var authorLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 16, weight: .semibold)
        lbl.textColor = UIColor(named: "PrimaryGradientStart")
        lbl.textAlignment = .center
        lbl.isUserInteractionEnabled = true
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private lazy var durationValueLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "—"
        lbl.font = .systemFont(ofSize: 17, weight: .bold)
        lbl.textColor = UIColor(named: "OnDarkTextPrimary")
        lbl.textAlignment = .center
        return lbl
    }()

    private lazy var statsView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private lazy var listenButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = UIColor(named: "PrimaryGradientStart")
        config.baseForegroundColor = UIColor(named: "OnDarkTextPrimary")
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

    private lazy var favoriteButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "heart"), for: .normal)
        btn.tintColor = UIColor(named: "OnDarkTextPrimary")
        btn.backgroundColor = UIColor(named: "FillGlassMedium")
        btn.layer.cornerRadius = 28
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private lazy var downloadButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "arrow.down.circle"), for: .normal)
        btn.tintColor = UIColor(named: "OnDarkTextPrimary")
        btn.backgroundColor = UIColor(named: "FillGlassMedium")
        btn.layer.cornerRadius = 28
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private lazy var inLibraryBadge: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(named: "InLibraryBadgeGreen")?.withAlphaComponent(0.9)
        v.layer.cornerRadius = 12
        v.isHidden = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private lazy var inLibraryLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 11, weight: .semibold)
        lbl.textColor = UIColor(named: "OnDarkTextPrimary")
        lbl.text = "✓ In Library"
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private lazy var aiSummaryContainer: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(named: "FillGlass")
        v.layer.cornerRadius = 20
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private lazy var aiHeaderLabel: UILabel = {
        let lbl = UILabel()
        let attachment = NSTextAttachment()
        attachment.image = UIImage(systemName: "sparkles")?.withTintColor(UIColor(named: "PrimaryGradientStart") ?? .systemPurple)
        let attrStr = NSMutableAttributedString(attachment: attachment)
        attrStr.append(NSAttributedString(string: "  AI Summary Highlights", attributes: [
            .font: UIFont.systemFont(ofSize: 16, weight: .bold),
            .foregroundColor: UIColor(named: "OnDarkTextPrimary") ?? UIColor.white
        ]))
        lbl.attributedText = attrStr
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private lazy var aiStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 14
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private lazy var descriptionTitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Description"
        lbl.font = .systemFont(ofSize: 18, weight: .bold)
        lbl.textColor = UIColor(named: "OnDarkTextPrimary")
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private lazy var descriptionLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 14)
        lbl.textColor = UIColor(named: "OnDarkText70")
        lbl.numberOfLines = 4
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private lazy var readMoreButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Read more", for: .normal)
        btn.setTitleColor(UIColor(named: "PrimaryGradientStart"), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private var isDescriptionExpanded = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "AppBackground")
        setupLayout()
        bindViewModel()
        configureByBookType()
        updateFavoriteButton()
        updateDownloadButton()
        updateLibraryBadge()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        updateDownloadButton()
        updateLibraryBadge()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
}

private extension BookDetailViewController {

    func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
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
        let authorTap = UITapGestureRecognizer(target: self, action: #selector(authorTapped))
        authorLabel.addGestureRecognizer(authorTap)
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
        let ratingItem = makeStatItem(value: "4.8", label: "RATING", icon: "star.fill", iconColor: UIColor(named: "RatingStarYellow") ?? .yellow)
        let durationItem = makeDurationStatItem()
        let languageItem = makeStatItem(value: "EN", label: "LANGUAGE", icon: "globe", iconColor: UIColor(named: "LanguageIconBlue") ?? .blue)
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
            divider1.centerXAnchor.constraint(equalTo: statsView.centerXAnchor, constant: -60),
            divider1.centerYAnchor.constraint(equalTo: statsView.centerYAnchor),
            divider1.widthAnchor.constraint(equalToConstant: 1),
            divider1.heightAnchor.constraint(equalToConstant: 36),
            durationItem.centerXAnchor.constraint(equalTo: statsView.centerXAnchor),
            durationItem.centerYAnchor.constraint(equalTo: statsView.centerYAnchor),
            divider2.centerXAnchor.constraint(equalTo: statsView.centerXAnchor, constant: 60),
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
        inLibraryBadge.addSubview(inLibraryLabel)
        contentView.addSubview(inLibraryBadge)
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
            favoriteButton.heightAnchor.constraint(equalToConstant: 56),
            inLibraryLabel.topAnchor.constraint(equalTo: inLibraryBadge.topAnchor, constant: 6),
            inLibraryLabel.bottomAnchor.constraint(equalTo: inLibraryBadge.bottomAnchor, constant: -6),
            inLibraryLabel.leadingAnchor.constraint(equalTo: inLibraryBadge.leadingAnchor, constant: 10),
            inLibraryLabel.trailingAnchor.constraint(equalTo: inLibraryBadge.trailingAnchor, constant: -10),
            inLibraryBadge.topAnchor.constraint(equalTo: listenButton.bottomAnchor, constant: 12),
            inLibraryBadge.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
        listenButton.addTarget(self, action: #selector(listenTapped), for: .touchUpInside)
        favoriteButton.addTarget(self, action: #selector(favTapped), for: .touchUpInside)
        downloadButton.addTarget(self, action: #selector(downloadTapped), for: .touchUpInside)
    }

    func setupAISummary() {
        contentView.addSubview(aiSummaryContainer)
        aiSummaryContainer.addSubview(aiHeaderLabel)
        aiSummaryContainer.addSubview(aiStackView)
        NSLayoutConstraint.activate([
            aiSummaryContainer.topAnchor.constraint(equalTo: inLibraryBadge.bottomAnchor, constant: 24),
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

private extension BookDetailViewController {

    func bindViewModel() {
        viewModel.onStateChanged = { [weak self] state in
            guard let self else { return }
            if case .success = state { self.populateData() }
        }
        viewModel.onAIUpdated = { [weak self] in
            guard let self else { return }
            self.buildAISummary(self.viewModel.aiSummary)
        }
    }
    

    func configureByBookType() {
        switch bookType {
        case .audiobook:
            headerLabel.text = "NOW PLAYING"
            updateListenButton(title: "Listen Now", icon: "play.fill")
            viewModel.fetchDetail()

        case .ebook(let ebook):
            headerLabel.text = "EBOOK"
            updateListenButton(title: "Read Now", icon: "book.fill")
            titleLabel.text = ebook.title
            authorLabel.text = ebook.authorName
            coverImageView.kf.setImage(with: ebook.coverURL)
            if ebook.downloadCount > 0 { durationValueLabel.text = "\(ebook.downloadCount)↓" }
            let vm = EbookDetailViewModel(ebook: ebook)
            ebookDetailVM = vm
            descriptionLabel.text = vm.description
            buildAISummary(vm.aiSummary)
        }
    }

    func updateListenButton(title: String, icon: String) {
        var config = listenButton.configuration
        config?.image = UIImage(systemName: icon)
        var attrTitle = AttributedString(title)
        attrTitle.font = .systemFont(ofSize: 16, weight: .bold)
        config?.attributedTitle = attrTitle
        listenButton.configuration = config
    }

    func populateData() {
        let book = viewModel.book
        titleLabel.text = book.title
        authorLabel.text = book.authorName
        descriptionLabel.text = book.description?.htmlStripped ?? "No description available."
        let url = book.coverURL ?? book.archiveCoverURL
        coverImageView.kf.setImage(with: url)
        if let sections = book.numSections?.value, sections > 0 {
            let hours = (sections * 30) / 60
            let mins  = (sections * 30) % 60
            durationValueLabel.text = hours > 0 ? (mins > 0 ? "\(hours)h \(mins)m" : "\(hours)h") : "\(mins)m"
        } else {
            durationValueLabel.text = "—"
        }
        buildAISummary(viewModel.aiSummary)
    }

    func buildAISummary(_ points: [String]) {
        aiStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (i, point) in points.enumerated() {
            aiStackView.addArrangedSubview(makeAISummaryRow(number: i + 1, text: point))
        }
    }

    func makeAISummaryRow(number: Int, text: String) -> UIView {
        let numLbl = UILabel()
        numLbl.text = String(format: "%02d", number)
        numLbl.font = .systemFont(ofSize: 13, weight: .bold)
        numLbl.textColor = UIColor(named: "PrimaryGradientStart")
        numLbl.translatesAutoresizingMaskIntoConstraints = false
        numLbl.setContentHuggingPriority(.required, for: .horizontal)
        let txtLbl = UILabel()
        txtLbl.text = text
        txtLbl.font = .systemFont(ofSize: 14)
        txtLbl.textColor = UIColor(named: "OnDarkText80")
        txtLbl.numberOfLines = 0
        txtLbl.translatesAutoresizingMaskIntoConstraints = false
        let stack = UIStackView(arrangedSubviews: [numLbl, txtLbl])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .top
        return stack
    }

    func makeDurationStatItem() -> UIStackView {
        let icon = UIImageView(image: UIImage(systemName: "clock"))
        icon.tintColor = UIColor(named: "PrimaryGradientStart")
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.widthAnchor.constraint(equalToConstant: 20).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 20).isActive = true
        let lbl = UILabel()
        lbl.text = "DURATION"
        lbl.font = .systemFont(ofSize: 10, weight: .medium)
        lbl.textColor = UIColor(named: "OnDarkTextDetail")
        lbl.textAlignment = .center
        let stack = UIStackView(arrangedSubviews: [icon, durationValueLabel, lbl])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 4
        return stack
    }

    func makeStatItem(value: String, label: String, icon: String, iconColor: UIColor) -> UIStackView {
        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = iconColor
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        iconView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        let valLbl = UILabel()
        valLbl.text = value
        valLbl.font = .systemFont(ofSize: 17, weight: .bold)
        valLbl.textColor = UIColor(named: "OnDarkTextPrimary")
        valLbl.textAlignment = .center
        let titleLbl = UILabel()
        titleLbl.text = label
        titleLbl.font = .systemFont(ofSize: 10, weight: .medium)
        titleLbl.textColor = UIColor(named: "OnDarkTextDetail")
        titleLbl.textAlignment = .center
        let stack = UIStackView(arrangedSubviews: [iconView, valLbl, titleLbl])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 4
        return stack
    }

    func makeDivider() -> UIView {
        let v = UIView()
        v.backgroundColor = UIColor(named: "FillGlassStrong")
        return v
    }

    func updateFavoriteButton() {
        let isFav = viewModel.isFavorited(bookType: bookType)
        favoriteButton.tintColor = isFav ? UIColor(named: "FavoriteActivePink") : UIColor(named: "OnDarkTextPrimary")
        favoriteButton.setImage(UIImage(systemName: isFav ? "heart.fill" : "heart"), for: .normal)
    }

    func updateDownloadButton() {
        switch bookType {
        case .audiobook:
            let saved = LibraryManager.shared.isDownloaded(id: String(viewModel.book.id.value))
            downloadButton.setImage(UIImage(systemName: saved ? "checkmark.circle.fill" : "arrow.down.circle"), for: .normal)
            downloadButton.tintColor = saved ? UIColor(named: "SuccessGreen") : UIColor(named: "OnDarkTextPrimary")
            downloadButton.isUserInteractionEnabled = !saved
        case .ebook(let ebook):
            let saved = LibraryManager.shared.isDownloaded(id: ebook.id)
            downloadButton.setImage(UIImage(systemName: saved ? "checkmark.circle.fill" : "arrow.down.circle"), for: .normal)
            downloadButton.tintColor = saved ? UIColor(named: "SuccessGreen") : UIColor(named: "OnDarkTextPrimary")
            downloadButton.isUserInteractionEnabled = !saved
        }
    }

    func updateLibraryBadge() {
        guard case .ebook(let ebook) = bookType else { inLibraryBadge.isHidden = true; return }
        inLibraryBadge.isHidden = !LibraryManager.shared.isDownloaded(id: ebook.id)
    }

    func fetchFirstAudioURL(from rssURL: URL, completion: @escaping (URL?) -> Void) {
        URLSession.shared.dataTask(with: rssURL) { data, _, _ in
            guard let data, let xml = String(data: data, encoding: .utf8) else {
                completion(nil); return
            }
            let pattern = #"<enclosure[^>]+url="([^"]+\.mp3)"#
            if let range = xml.range(of: pattern, options: .regularExpression),
               let urlRange = xml[range].range(of: #"url="([^"]+)"#, options: .regularExpression) {
                let urlString = String(xml[range][urlRange])
                    .replacingOccurrences(of: "url=\"", with: "")
                    .replacingOccurrences(of: "\"", with: "")
                completion(URL(string: urlString))
            } else {
                completion(nil)
            }
        }.resume()
    }
}

extension BookDetailViewController {

    @objc func listenTapped() {
        switch bookType {
        case .audiobook:
            let book = viewModel.book
            if let rssString = book.urlRss, let rssURL = URL(string: rssString) {
                fetchFirstAudioURL(from: rssURL) { [weak self] audioURL in
                    DispatchQueue.main.async {
                        PlayerManager.shared.play(book: book, previewURL: audioURL)
                        let playerVC = PlayerViewController()
                        playerVC.modalPresentationStyle = .fullScreen
                        self?.present(playerVC, animated: true)
                    }
                }
            } else {
                PlayerManager.shared.play(book: book)
                let playerVC = PlayerViewController()
                playerVC.modalPresentationStyle = .fullScreen
                present(playerVC, animated: true)
            }
        case .ebook(let ebook):
            navigationController?.pushViewController(EbookReaderViewController(ebook: ebook), animated: true)
        }
    }

    @objc func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc func authorTapped() {
        let author: Author?
        switch bookType {
        case .audiobook: author = viewModel.book.authors?.first
        case .ebook(let ebook): author = Author(firstName: ebook.authorName, lastName: nil)
        }
        guard let author else { return }
        navigationController?.pushViewController(AuthorDetailViewController(author: author), animated: true)
    }

    @objc func favTapped() {
        viewModel.toggleFavorite(bookType: bookType)
        updateFavoriteButton()
    }

    @objc func downloadTapped() {
        switch bookType {
        case .audiobook:
            LibraryManager.shared.saveAudiobook(viewModel.book)
            updateDownloadButton()
        case .ebook(let ebook):
            navigationController?.pushViewController(EbookReaderViewController(ebook: ebook), animated: true)
        }
    }

    @objc func readMoreTapped() {
        isDescriptionExpanded.toggle()
        descriptionLabel.numberOfLines = isDescriptionExpanded ? 0 : 4
        readMoreButton.setTitle(isDescriptionExpanded ? "Show less" : "Read more", for: .normal)
        UIView.animate(withDuration: 0.3) { self.view.layoutIfNeeded() }
    }
}

private extension String {
    var htmlStripped: String {
        guard let data = data(using: .utf8),
              let attr = try? NSAttributedString(
                data: data,
                options: [.documentType: NSAttributedString.DocumentType.html,
                          .characterEncoding: String.Encoding.utf8.rawValue],
                documentAttributes: nil)
        else { return self }
        return attr.string
    }
}
