//
//  GenreViewController.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 02.03.26.
//
import UIKit

final class GenreViewController: UIViewController {

    // MARK: - Properties

    weak var coordinator: HomeCoordinator?
    private let viewModel: GenreViewModel

    private var selectedTab: GenreTab = .audiobooks {
        didSet {
            updateTabIndicator()
            collectionView.reloadData()
        }
    }

    // MARK: - UI

    private var collectionView: UICollectionView!

    private let headerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let backButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        btn.tintColor = .white
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 22, weight: .bold)
        lbl.textColor = .white
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let tabContainer: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        v.layer.cornerRadius = 14
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let tabIndicator: UIView = {
        let v = UIView()
        v.backgroundColor = .systemPurple
        v.layer.cornerRadius = 11
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let audiobooksTabBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Audiobooks", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        btn.tintColor = .white
        btn.tag = 0
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let booksTabBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Books", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        btn.tintColor = UIColor.white.withAlphaComponent(0.5)
        btn.tag = 1
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let loadingFooter: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .medium)
        ai.color = .systemPurple
        return ai
    }()

    private var indicatorLeading: NSLayoutConstraint!

    // MARK: - Init

    init(viewModel: GenreViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "AppBackground")
        setupHeader()
        setupTabBar()
        setupCollectionView()
        bindViewModel()
        viewModel.fetchInitial()
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

// MARK: - Setup

private extension GenreViewController {

    func setupHeader() {
        view.addSubview(headerView)
        headerView.addSubview(backButton)
        headerView.addSubview(titleLabel)

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
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])

        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
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

        indicatorLeading = tabIndicator.leadingAnchor.constraint(
            equalTo: tabContainer.leadingAnchor, constant: 3
        )
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

        collectionView.register(GenreBookCell.self,      forCellWithReuseIdentifier: GenreBookCell.identifier)
        collectionView.register(GenreEbookCell.self,     forCellWithReuseIdentifier: GenreEbookCell.identifier)
        collectionView.register(GenreLoadingCell.self,   forCellWithReuseIdentifier: GenreLoadingCell.identifier)

        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: tabContainer.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func bindViewModel() {
        viewModel.onDataUpdated = { [weak self] in
            self?.collectionView.reloadData()
        }
        viewModel.onError = { [weak self] msg in
            print("Genre error:", msg)
        }
        viewModel.onLoadingChanged = { [weak self] in
            self?.collectionView.reloadData()
        }
    }

    func updateTabIndicator() {
        let isAudio = selectedTab == .audiobooks
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
            self.indicatorLeading.constant = isAudio ? 3 : 120
            self.tabContainer.layoutIfNeeded()
        }
        audiobooksTabBtn.tintColor = isAudio ? .white : UIColor.white.withAlphaComponent(0.5)
        booksTabBtn.tintColor      = isAudio ? UIColor.white.withAlphaComponent(0.5) : .white
    }
}

// MARK: - Layout

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

// MARK: - DataSource

extension GenreViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        let count = viewModel.items(for: selectedTab)
        // Son item loading spinner üçün
        let showLoader = viewModel.isLoading(for: selectedTab) && count > 0
        return showLoader ? count + 1 : count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let count = viewModel.items(for: selectedTab)

        // Son item — loading spinner
        if indexPath.item == count {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: GenreLoadingCell.identifier, for: indexPath
            ) as! GenreLoadingCell
            cell.startAnimating()
            return cell
        }

        if selectedTab == .audiobooks {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: GenreBookCell.identifier, for: indexPath
            ) as! GenreBookCell
            cell.configure(with: viewModel.audiobooks[indexPath.item])
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: GenreEbookCell.identifier, for: indexPath
            ) as! GenreEbookCell
            cell.configure(with: viewModel.ebooks[indexPath.item])
            return cell
        }
    }
}

// MARK: - Delegate

extension GenreViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        if viewModel.shouldFetchNextPage(for: selectedTab, at: indexPath.item) {
            if selectedTab == .audiobooks {
                viewModel.fetchNextAudiobookPage()
            } else {
                viewModel.fetchNextEbookPage()
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        let count = viewModel.items(for: selectedTab)
        guard indexPath.item < count else { return }

        if selectedTab == .audiobooks {
            coordinator?.showBookDetail(book: viewModel.audiobooks[indexPath.item])
        } else {
            coordinator?.showEbookDetail(ebook: viewModel.ebooks[indexPath.item])
        }
    }
}

// MARK: - Actions

private extension GenreViewController {

    @objc func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc func tabTapped(_ sender: UIButton) {
        let newTab: GenreTab = sender.tag == 0 ? .audiobooks : .books
        guard newTab != selectedTab else { return }
        selectedTab = newTab
    }
}
