//
//  AuthorDetailViewController.swift
//  EchoShelf
//
import UIKit
import Kingfisher

final class AuthorDetailViewController: UIViewController {

    private let viewModel: AuthorDetailViewModel
    private let favoritesViewModel = FavoritesViewModel()

    init(author: Author) {
        self.viewModel = AuthorDetailViewModel(author: author)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    private enum Section: Int, CaseIterable {
        case audiobooks
        case ebooks

        var title: String {
            switch self {
            case .audiobooks: return "Audiobooks"
            case .ebooks:     return "Books"
            }
        }
    }

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

    private lazy var backButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "chevron.left")
        config.baseForegroundColor = UIColor(named: "OnDarkTextPrimary")
        let btn = UIButton(configuration: config)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private lazy var favoriteButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "heart"), for: .normal)
        btn.tintColor = UIColor(named: "OnDarkTextPrimary")
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private lazy var photoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 60
        iv.backgroundColor = UIColor(named: "FillGlass")
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private lazy var nameLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 28, weight: .bold)
        lbl.textColor = UIColor(named: "OnDarkTextPrimary")
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private lazy var bioLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 15)
        lbl.textColor = UIColor(named: "OnDarkTextSecondary")
        lbl.numberOfLines = 0
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        cv.backgroundColor = .clear
        cv.isScrollEnabled = false
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(TrendingBookCell.self, forCellWithReuseIdentifier: TrendingBookCell.identifier)
        cv.register(EbookTrendingCell.self, forCellWithReuseIdentifier: EbookTrendingCell.identifier)
        cv.register(
            AuthorSectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: AuthorSectionHeaderView.identifier
        )
        return cv
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .large)
        ai.color = UIColor(named: "PrimaryGradientStart")
        ai.hidesWhenStopped = true
        ai.translatesAutoresizingMaskIntoConstraints = false
        return ai
    }()

    private var collectionHeightConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "AppBackground")
        setupUI()
        setupActions()
        bindViewModel()
        viewModel.fetchData()
        updateFavoriteButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        view.addSubview(backButton)
        view.addSubview(favoriteButton)
        view.addSubview(activityIndicator)

        contentView.addSubview(photoImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(bioLabel)
        contentView.addSubview(collectionView)

        collectionView.dataSource = self
        collectionView.delegate = self

        collectionHeightConstraint = collectionView.heightAnchor.constraint(equalToConstant: 0)

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

            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),

            favoriteButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            favoriteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            photoImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 80),
            photoImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            photoImageView.widthAnchor.constraint(equalToConstant: 120),
            photoImageView.heightAnchor.constraint(equalToConstant: 120),

            nameLabel.topAnchor.constraint(equalTo: photoImageView.bottomAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            bioLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 16),
            bioLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            bioLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            collectionView.topAnchor.constraint(equalTo: bioLabel.bottomAnchor, constant: 24),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionHeightConstraint,
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }

    private func setupActions() {
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        favoriteButton.addTarget(self, action: #selector(favTapped), for: .touchUpInside)
    }

    private func bindViewModel() {
        viewModel.onStateChanged = { [weak self] state in
            guard let self else { return }
            switch state {
            case .loading:
                self.activityIndicator.startAnimating()
            case .success:
                self.activityIndicator.stopAnimating()
                self.updateHeaderUI()
                self.reloadCollectionHeight()
            case .failure:
                self.activityIndicator.stopAnimating()
            case .idle:
                break
            }
        }

        viewModel.onAudiobooksUpdated = { [weak self] in
            self?.reloadCollectionHeight()
        }

        viewModel.onEbooksUpdated = { [weak self] in
            self?.reloadCollectionHeight()
        }
    }

    private func updateHeaderUI() {
        nameLabel.text = viewModel.fullName

        if let photoURL = viewModel.authorDetail?.photoURL {
            photoImageView.kf.setImage(with: photoURL, placeholder: UIImage(systemName: "person.circle.fill"))
        } else {
            photoImageView.image = UIImage(systemName: "person.circle.fill")
            photoImageView.tintColor = UIColor(named: "OnDarkTextSecondary")
        }

        bioLabel.text = viewModel.authorDetail?.bio ?? "No biography available."
    }

    private func reloadCollectionHeight() {
        let audiobookRows = ceil(Double(viewModel.audiobooks.count) / 2.0)
        let ebookRows = ceil(Double(viewModel.ebooks.count) / 2.0)
        let headerHeight: CGFloat = 50
        collectionHeightConstraint.constant = (audiobookRows + ebookRows) * 260 + headerHeight * 2 + 48
        collectionView.reloadData()
        view.layoutIfNeeded()
    }

    private func updateFavoriteButton() {
        let isFav = favoritesViewModel.isAuthorFavorited(viewModel.author)
        favoriteButton.tintColor = isFav ? UIColor(named: "FavoriteActivePink") : UIColor(named: "OnDarkTextPrimary")
        favoriteButton.setImage(UIImage(systemName: isFav ? "heart.fill" : "heart"), for: .normal)
    }

    private func createLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { _, _ in
            let item = NSCollectionLayoutItem(
                layoutSize: .init(widthDimension: .fractionalWidth(0.5), heightDimension: .absolute(240))
            )
            item.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 12)
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(240)),
                subitems: [item, item]
            )
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 16
            section.contentInsets = .init(top: 8, leading: 20, bottom: 24, trailing: 8)
            section.boundarySupplementaryItems = [
                NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50)),
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )
            ]
            return section
        }
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func favTapped() {
        favoritesViewModel.toggleAuthor(viewModel.author)
        updateFavoriteButton()
        NotificationCenter.default.post(name: .favoritesDidChange, object: nil)
    }
}

extension AuthorDetailViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        Section.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .audiobooks: return viewModel.audiobooks.count
        case .ebooks:     return viewModel.ebooks.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch Section(rawValue: indexPath.section)! {
        case .audiobooks:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrendingBookCell.identifier, for: indexPath) as! TrendingBookCell
            cell.configure(with: viewModel.audiobooks[indexPath.item])
            return cell
        case .ebooks:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EbookTrendingCell.identifier, for: indexPath) as! EbookTrendingCell
            cell.configure(with: viewModel.ebooks[indexPath.item])
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: AuthorSectionHeaderView.identifier,
            for: indexPath
        ) as! AuthorSectionHeaderView
        header.configure(Section(rawValue: indexPath.section)!.title)
        return header
    }
}

extension AuthorDetailViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        switch Section(rawValue: indexPath.section)! {
        case .audiobooks:
            if indexPath.item == viewModel.audiobooks.count - 4 {
                viewModel.fetchNextAudiobooks()
            }
        case .ebooks:
            if indexPath.item == viewModel.ebooks.count - 4 {
                viewModel.fetchNextEbooks()
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch Section(rawValue: indexPath.section)! {
        case .audiobooks:
            let book = viewModel.audiobooks[indexPath.item]
            navigationController?.pushViewController(BookDetailViewController(book: book), animated: true)
        case .ebooks:
            let ebook = viewModel.ebooks[indexPath.item]
            navigationController?.pushViewController(BookDetailViewController(ebook: ebook), animated: true)
        }
    }
}

final class AuthorSectionHeaderView: UICollectionReusableView {

    static let identifier = "AuthorSectionHeaderView"

    private lazy var titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 20, weight: .bold)
        lbl.textColor = UIColor(named: "OnDarkTextPrimary")
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(_ title: String) {
        titleLabel.text = title
    }
}
