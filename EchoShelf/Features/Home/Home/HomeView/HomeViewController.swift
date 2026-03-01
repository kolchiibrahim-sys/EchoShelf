//
//  HomeViewController.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 21.02.26.
//
import UIKit

enum HomeSection: Int, CaseIterable {
    case header
    case continueListening
    case genres
    case trending
    case recommended
}

final class HomeViewController: UIViewController {

    weak var coordinator: HomeCoordinator?

    private let viewModel = HomeViewModel()

    private var collectionView: UICollectionView!

    // MARK: - Top Tab

    private var selectedTab: HomeTab = .audiobooks {
        didSet {
            updateTabIndicator()
            collectionView.reloadData()
        }
    }

    private let tabContainer: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        v.layer.cornerRadius = 16
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let tabIndicator: UIView = {
        let v = UIView()
        v.backgroundColor = .systemPurple
        v.layer.cornerRadius = 13
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let audiobooksTabButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Audiobooks", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        btn.tintColor = .white
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.tag = 0
        return btn
    }()

    private let booksTabButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Books", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        btn.tintColor = UIColor.white.withAlphaComponent(0.5)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.tag = 1
        return btn
    }()

    private var indicatorLeadingConstraint: NSLayoutConstraint!

    private let genres = [
        "Fantasy", "Drama", "Romance", "Mystery",
        "Sci-Fi", "History", "Adventure", "Kids"
    ]

    // Computed shortcuts
    private var trendingItems: Int {
        selectedTab == .audiobooks
            ? viewModel.trendingAudiobooks.count
            : viewModel.trendingEbooks.count
    }

    private var recommendedItems: Int {
        selectedTab == .audiobooks
            ? viewModel.recommendedAudiobooks.count
            : viewModel.recommendedEbooks.count
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "AppBackground")
        setupTopTab()
        setupCollectionView()
        bindViewModel()
        viewModel.fetchBooks()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}

// MARK: - Top Tab Setup

private extension HomeViewController {

    func setupTopTab() {
        view.addSubview(tabContainer)
        tabContainer.addSubview(tabIndicator)
        tabContainer.addSubview(audiobooksTabButton)
        tabContainer.addSubview(booksTabButton)

        NSLayoutConstraint.activate([
            tabContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            tabContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tabContainer.widthAnchor.constraint(equalToConstant: 260),
            tabContainer.heightAnchor.constraint(equalToConstant: 40),

            audiobooksTabButton.leadingAnchor.constraint(equalTo: tabContainer.leadingAnchor),
            audiobooksTabButton.topAnchor.constraint(equalTo: tabContainer.topAnchor),
            audiobooksTabButton.bottomAnchor.constraint(equalTo: tabContainer.bottomAnchor),
            audiobooksTabButton.widthAnchor.constraint(equalTo: tabContainer.widthAnchor, multiplier: 0.5),

            booksTabButton.trailingAnchor.constraint(equalTo: tabContainer.trailingAnchor),
            booksTabButton.topAnchor.constraint(equalTo: tabContainer.topAnchor),
            booksTabButton.bottomAnchor.constraint(equalTo: tabContainer.bottomAnchor),
            booksTabButton.widthAnchor.constraint(equalTo: tabContainer.widthAnchor, multiplier: 0.5),

            tabIndicator.topAnchor.constraint(equalTo: tabContainer.topAnchor, constant: 3),
            tabIndicator.bottomAnchor.constraint(equalTo: tabContainer.bottomAnchor, constant: -3),
            tabIndicator.widthAnchor.constraint(equalTo: tabContainer.widthAnchor, multiplier: 0.5, constant: -3)
        ])

        indicatorLeadingConstraint = tabIndicator.leadingAnchor.constraint(
            equalTo: tabContainer.leadingAnchor, constant: 3
        )
        indicatorLeadingConstraint.isActive = true

        audiobooksTabButton.addTarget(self, action: #selector(tabTapped(_:)), for: .touchUpInside)
        booksTabButton.addTarget(self, action: #selector(tabTapped(_:)), for: .touchUpInside)
    }

    @objc func tabTapped(_ sender: UIButton) {
        let newTab: HomeTab = sender.tag == 0 ? .audiobooks : .books
        guard newTab != selectedTab else { return }
        selectedTab = newTab
    }

    func updateTabIndicator() {
        let isAudiobooks = selectedTab == .audiobooks

        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
            self.indicatorLeadingConstraint.constant = isAudiobooks ? 3 : 130
            self.tabContainer.layoutIfNeeded()
        }

        audiobooksTabButton.tintColor = isAudiobooks ? .white : UIColor.white.withAlphaComponent(0.5)
        booksTabButton.tintColor = isAudiobooks ? UIColor.white.withAlphaComponent(0.5) : .white
    }
}

// MARK: - Collection Setup

private extension HomeViewController {

    func setupCollectionView() {
        collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: createLayout()
        )
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = false

        collectionView.register(HomeHeaderCell.self,          forCellWithReuseIdentifier: HomeHeaderCell.identifier)
        collectionView.register(ContinueListeningCell.self,   forCellWithReuseIdentifier: ContinueListeningCell.identifier)
        collectionView.register(TrendingBookCell.self,        forCellWithReuseIdentifier: TrendingBookCell.identifier)
        collectionView.register(EbookTrendingCell.self,       forCellWithReuseIdentifier: EbookTrendingCell.identifier)
        collectionView.register(GenreCell.self,               forCellWithReuseIdentifier: GenreCell.identifier)
        collectionView.register(RecommendedBookCell.self,     forCellWithReuseIdentifier: RecommendedBookCell.identifier)
        collectionView.register(EbookRecommendedCell.self,    forCellWithReuseIdentifier: EbookRecommendedCell.identifier)

        collectionView.register(
            HomeSectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: HomeSectionHeaderView.identifier
        )

        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: tabContainer.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func bindViewModel() {
        viewModel.onDataUpdated = { [weak self] in
            self?.collectionView.reloadData()
        }
    }

    func titleForSection(_ section: HomeSection) -> String? {
        switch section {
        case .continueListening: return selectedTab == .audiobooks ? "Continue Listening" : "Continue Reading"
        case .genres:            return "Genres"
        case .trending:          return selectedTab == .audiobooks ? "Trending Audiobooks" : "Trending Books"
        case .recommended:       return selectedTab == .audiobooks ? "Recommended For You" : "You Might Like"
        default:                 return nil
        }
    }

    func showViewAllForSection(_ section: HomeSection) -> Bool {
        switch section {
        case .trending, .recommended: return true
        default: return false
        }
    }
}

// MARK: - DataSource

extension HomeViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        HomeSection.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        switch HomeSection(rawValue: section)! {
        case .header:            return 1
        case .continueListening: return 1
        case .genres:            return genres.count
        case .trending:          return trendingItems
        case .recommended:       return recommendedItems
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch HomeSection(rawValue: indexPath.section)! {

        case .header:
            return collectionView.dequeueReusableCell(
                withReuseIdentifier: HomeHeaderCell.identifier, for: indexPath)

        case .continueListening:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ContinueListeningCell.identifier, for: indexPath
            ) as! ContinueListeningCell
            cell.configure()
            return cell

        case .genres:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: GenreCell.identifier, for: indexPath
            ) as! GenreCell
            cell.configure(genres[indexPath.item])
            return cell

        case .trending:
            if selectedTab == .audiobooks {
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: TrendingBookCell.identifier, for: indexPath
                ) as! TrendingBookCell
                cell.configure(with: viewModel.trendingAudiobooks[indexPath.item])
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: EbookTrendingCell.identifier, for: indexPath
                ) as! EbookTrendingCell
                cell.configure(with: viewModel.trendingEbooks[indexPath.item])
                return cell
            }

        case .recommended:
            if selectedTab == .audiobooks {
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: RecommendedBookCell.identifier, for: indexPath
                ) as! RecommendedBookCell
                cell.configure(with: viewModel.recommendedAudiobooks[indexPath.item])
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: EbookRecommendedCell.identifier, for: indexPath
                ) as! EbookRecommendedCell
                cell.configure(with: viewModel.recommendedEbooks[indexPath.item])
                return cell
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }

        let section = HomeSection(rawValue: indexPath.section)!
        guard let title = titleForSection(section) else {
            return UICollectionReusableView()
        }

        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: HomeSectionHeaderView.identifier,
            for: indexPath
        ) as! HomeSectionHeaderView

        header.configure(title, showViewAll: showViewAllForSection(section))

        header.onViewAll = { [weak self] in
            guard let self else { return }
            switch section {
            case .trending:    self.coordinator?.showAllBooks(type: .trending)
            case .recommended: self.coordinator?.showAllBooks(type: .recommended)
            default: break
            }
        }

        return header
    }
}

// MARK: - Delegate

extension HomeViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        switch HomeSection(rawValue: indexPath.section)! {

        case .trending:
            if selectedTab == .audiobooks {
                coordinator?.showBookDetail(book: viewModel.trendingAudiobooks[indexPath.item])
            } else {
                coordinator?.showEbookDetail(ebook: viewModel.trendingEbooks[indexPath.item])
            }

        case .recommended:
            if selectedTab == .audiobooks {
                coordinator?.showBookDetail(book: viewModel.recommendedAudiobooks[indexPath.item])
            } else {
                coordinator?.showEbookDetail(ebook: viewModel.recommendedEbooks[indexPath.item])
            }

        case .genres:
            coordinator?.showGenreSearch(genre: genres[indexPath.item])

        default:
            break
        }
    }
}

// MARK: - Layout

private extension HomeViewController {

    func createLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { sectionIndex, _ in
            switch HomeSection(rawValue: sectionIndex)! {
            case .header:            return self.headerSection()
            case .continueListening: return self.continueSection()
            case .genres:            return self.genresSection()
            case .trending:          return self.trendingSection()
            case .recommended:       return self.recommendedSection()
            }
        }
    }

    func makeHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: .init(widthDimension: .fractionalWidth(1),
                              heightDimension: .absolute(40)),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
    }

    func headerSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(80))
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: item.layoutSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 16, leading: 20, bottom: 0, trailing: 20)
        return section
    }

    func continueSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(120))
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: item.layoutSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 10, leading: 20, bottom: 0, trailing: 20)
        section.boundarySupplementaryItems = [makeHeader()]
        return section
    }

    func genresSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: .init(widthDimension: .absolute(100), heightDimension: .absolute(36))
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(widthDimension: .estimated(100), heightDimension: .absolute(36)),
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 12
        section.contentInsets = .init(top: 20, leading: 20, bottom: 0, trailing: 20)
        section.boundarySupplementaryItems = [makeHeader()]
        return section
    }

    func trendingSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: .init(widthDimension: .absolute(150), heightDimension: .absolute(240))
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(widthDimension: .absolute(150), heightDimension: .absolute(240)),
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 16
        section.contentInsets = .init(top: 12, leading: 20, bottom: 8, trailing: 20)
        section.boundarySupplementaryItems = [makeHeader()]
        return section
    }

    func recommendedSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(116))
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: item.layoutSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 12
        section.contentInsets = .init(top: 12, leading: 20, bottom: 40, trailing: 20)
        section.boundarySupplementaryItems = [makeHeader()]
        return section
    }
}
