//
//  GenreViewController.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 02.03.26.
//
import UIKit

final class GenreViewController: UIViewController {

    weak var coordinator: HomeCoordinator?
    private let viewModel: GenreViewModel
    private let favoritesViewModel = FavoritesViewModel()
    private var selectedTab: GenreTab = .audiobooks {
        didSet {
            updateTabIndicator()
            collectionView.reloadData()
        }
    }
    private var collectionView: UICollectionView!

    private lazy var headerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private lazy var backButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        btn.tintColor = UIColor(named: "OnDarkTextPrimary")
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private lazy var titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 22, weight: .bold)
        lbl.textColor = UIColor(named: "OnDarkTextPrimary")
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private lazy var infoButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "info.circle"), for: .normal)
        btn.tintColor = UIColor(named: "OnDarkTextSecondary")
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

    private lazy var tabContainer: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(named: "FillGlass")
        v.layer.cornerRadius = 14
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private lazy var tabIndicator: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(named: "PrimaryGradientStart")
        v.layer.cornerRadius = 11
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private lazy var audiobooksTabBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Audiobooks", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        btn.tintColor = UIColor(named: "OnDarkTextPrimary")
        btn.tag = 0
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private lazy var booksTabBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Books", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        btn.tintColor = UIColor(named: "TabTextInactive")
        btn.tag = 1
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private var indicatorLeading: NSLayoutConstraint!

    private var genreData: Genre? {
        Genre.all.first { $0.name.lowercased() == viewModel.genre.lowercased() }
    }

    init(viewModel: GenreViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "AppBackground")
        setupHeader()
        setupTabBar()
        setupCollectionView()
        bindViewModel()
        viewModel.fetchInitial()
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
}

private extension GenreViewController {

    func setupHeader() {
        view.addSubview(headerView)
        headerView.addSubview(backButton)
        headerView.addSubview(titleLabel)
        headerView.addSubview(infoButton)
        headerView.addSubview(favoriteButton)

        titleLabel.text = viewModel.genre

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 50),

            backButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            backButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 36),
            backButton.heightAnchor.constraint(equalToConstant: 36),

            titleLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 8),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            favoriteButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            favoriteButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            favoriteButton.widthAnchor.constraint(equalToConstant: 36),
            favoriteButton.heightAnchor.constraint(equalToConstant: 36),

            infoButton.trailingAnchor.constraint(equalTo: favoriteButton.leadingAnchor, constant: -8),
            infoButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            infoButton.widthAnchor.constraint(equalToConstant: 36),
            infoButton.heightAnchor.constraint(equalToConstant: 36)
        ])

        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        infoButton.addTarget(self, action: #selector(infoTapped), for: .touchUpInside)
        favoriteButton.addTarget(self, action: #selector(favTapped), for: .touchUpInside)
    }

    func setupTabBar() {
        view.addSubview(tabContainer)
        tabContainer.addSubview(tabIndicator)
        tabContainer.addSubview(audiobooksTabBtn)
        tabContainer.addSubview(booksTabBtn)

        NSLayoutConstraint.activate([
            tabContainer.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 10),
            tabContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tabContainer.widthAnchor.constraint(equalToConstant: 240),
            tabContainer.heightAnchor.constraint(equalToConstant: 36),

            audiobooksTabBtn.leadingAnchor.constraint(equalTo: tabContainer.leadingAnchor),
            audiobooksTabBtn.topAnchor.constraint(equalTo: tabContainer.topAnchor),
            audiobooksTabBtn.bottomAnchor.constraint(equalTo: tabContainer.bottomAnchor),
            audiobooksTabBtn.widthAnchor.constraint(equalTo: tabContainer.widthAnchor, multiplier: 0.5),

            booksTabBtn.trailingAnchor.constraint(equalTo: tabContainer.trailingAnchor),
            booksTabBtn.topAnchor.constraint(equalTo: tabContainer.topAnchor),
            booksTabBtn.bottomAnchor.constraint(equalTo: tabContainer.bottomAnchor),
            booksTabBtn.widthAnchor.constraint(equalTo: tabContainer.widthAnchor, multiplier: 0.5),

            tabIndicator.topAnchor.constraint(equalTo: tabContainer.topAnchor, constant: 3),
            tabIndicator.bottomAnchor.constraint(equalTo: tabContainer.bottomAnchor, constant: -3),
            tabIndicator.widthAnchor.constraint(equalTo: tabContainer.widthAnchor, multiplier: 0.5, constant: -3)
        ])

        indicatorLeading = tabIndicator.leadingAnchor.constraint(equalTo: tabContainer.leadingAnchor, constant: 3)
        indicatorLeading.isActive = true

        audiobooksTabBtn.addTarget(self, action: #selector(tabTapped(_:)), for: .touchUpInside)
        booksTabBtn.addTarget(self, action: #selector(tabTapped(_:)), for: .touchUpInside)
    }

    func setupCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = false

        collectionView.register(GenreBookCell.self, forCellWithReuseIdentifier: GenreBookCell.identifier)
        collectionView.register(GenreEbookCell.self, forCellWithReuseIdentifier: GenreEbookCell.identifier)
        collectionView.register(GenreLoadingCell.self, forCellWithReuseIdentifier: GenreLoadingCell.identifier)

        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: tabContainer.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func bindViewModel() {
        viewModel.onDataUpdated = { [weak self] in self?.collectionView.reloadData() }
        viewModel.onError = { msg in print("Genre error:", msg) }
        viewModel.onLoadingChanged = { [weak self] in self?.collectionView.reloadData() }
    }

    func updateTabIndicator() {
        let isAudio = selectedTab == .audiobooks
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
            self.indicatorLeading.constant = isAudio ? 3 : 120
            self.tabContainer.layoutIfNeeded()
        }
        audiobooksTabBtn.tintColor = isAudio ? UIColor(named: "OnDarkTextPrimary") : UIColor(named: "TabTextInactive")
        booksTabBtn.tintColor      = isAudio ? UIColor(named: "TabTextInactive") : UIColor(named: "OnDarkTextPrimary")
    }

    func updateFavoriteButton() {
        let isFav = favoritesViewModel.isGenreFavorited(viewModel.genre)
        favoriteButton.setImage(UIImage(systemName: isFav ? "heart.fill" : "heart"), for: .normal)
        favoriteButton.tintColor = isFav ? UIColor(named: "FavoriteActivePink") : UIColor(named: "OnDarkTextPrimary")
    }
}

private extension GenreViewController {

    func createLayout() -> UICollectionViewLayout {
        let item = NSCollectionLayoutItem(
            layoutSize: .init(widthDimension: .fractionalWidth(0.5), heightDimension: .absolute(230))
        )
        item.contentInsets = .init(top: 0, leading: 6, bottom: 0, trailing: 6)
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(230)),
            subitems: [item, item]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 16
        section.contentInsets = .init(top: 0, leading: 14, bottom: 40, trailing: 14)
        return UICollectionViewCompositionalLayout(section: section)
    }
}

extension GenreViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = viewModel.items(for: selectedTab)
        let showLoader = viewModel.isLoading(for: selectedTab) && count > 0
        return showLoader ? count + 1 : count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let count = viewModel.items(for: selectedTab)
        if indexPath.item == count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GenreLoadingCell.identifier, for: indexPath) as! GenreLoadingCell
            cell.startAnimating()
            return cell
        }
        if selectedTab == .audiobooks {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GenreBookCell.identifier, for: indexPath) as! GenreBookCell
            cell.configure(with: viewModel.audiobooks[indexPath.item])
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GenreEbookCell.identifier, for: indexPath) as! GenreEbookCell
            cell.configure(with: viewModel.ebooks[indexPath.item])
            return cell
        }
    }
}

extension GenreViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if viewModel.shouldFetchNextPage(for: selectedTab, at: indexPath.item) {
            if selectedTab == .audiobooks {
                viewModel.fetchNextAudiobookPage()
            } else {
                viewModel.fetchNextEbookPage()
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let count = viewModel.items(for: selectedTab)
        guard indexPath.item < count else { return }
        if selectedTab == .audiobooks {
            coordinator?.showBookDetail(book: viewModel.audiobooks[indexPath.item])
        } else {
            coordinator?.showEbookDetail(ebook: viewModel.ebooks[indexPath.item])
        }
    }
}

private extension GenreViewController {

    @objc func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc func tabTapped(_ sender: UIButton) {
        let newTab: GenreTab = sender.tag == 0 ? .audiobooks : .books
        guard newTab != selectedTab else { return }
        selectedTab = newTab
    }

    @objc func infoTapped() {
        let description = genreData?.description ?? "\(viewModel.genre) — a collection of great books in this category."
        let icon = genreData?.icon ?? "📚"
        let alert = UIAlertController(
            title: "\(icon) \(viewModel.genre)",
            message: description,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @objc func favTapped() {
        favoritesViewModel.toggleGenre(viewModel.genre)
        updateFavoriteButton()
        NotificationCenter.default.post(name: .favoritesDidChange, object: nil)
    }
}
