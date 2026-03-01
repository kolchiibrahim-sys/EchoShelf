//
//  SearchViewController.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 21.02.26.
//
import UIKit

final class SearchViewController: UIViewController {

    weak var coordinator: HomeCoordinator?
    var favoritesViewModel: FavoritesViewModel?

    var preselectedGenre: String? {
        didSet {
            guard let genre = preselectedGenre, isViewLoaded else { return }
            triggerGenreSearch(genre)
        }
    }

    // MARK: - UI

    private var collectionView: UICollectionView!
    private let searchBarView = SearchBarView()
    private let viewModel = SearchViewModel()

    private var isSearching = false

    // Trending Categories data
    private let trendingCategories: [TrendingCategory] = [
        TrendingCategory(title: "AI Picks",    icon: "🤖", colors: [UIColor(hex: "#6C5CE7"), UIColor(hex: "#4834D4")], query: "science",         subject: "Science Fiction"),
        TrendingCategory(title: "Bestsellers", icon: "🔥", colors: [UIColor(hex: "#E55039"), UIColor(hex: "#E74C3C")], query: "adventure",       subject: "Adventure"),
        TrendingCategory(title: "Sci-Fi",      icon: "🚀", colors: [UIColor(hex: "#00B894"), UIColor(hex: "#00897B")], query: "science fiction", subject: "Science Fiction"),
        TrendingCategory(title: "Thriller",    icon: "👁",  colors: [UIColor(hex: "#F39C12"), UIColor(hex: "#E67E22")], query: "mystery",         subject: "Mystery & Detective Stories"),
        TrendingCategory(title: "Classics",    icon: "📖", colors: [UIColor(hex: "#A855F7"), UIColor(hex: "#7C3AED")], query: "classic",         subject: "General Fiction"),
        TrendingCategory(title: "Narrators",   icon: "🎙", colors: [UIColor(hex: "#3B82F6"), UIColor(hex: "#2563EB")], query: "drama",           subject: "Plays")
    ]

    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No results found"
        label.textColor = UIColor.white.withAlphaComponent(0.6)
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var recentSearches: [String] { viewModel.recentSearches }

    // MARK: - Sections (non-searching state)
    private enum HomeSection: Int, CaseIterable {
        case recents    = 0
        case trending   = 1
        case youMightLike = 2
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "AppBackground")
        setupSearchBar()
        setupCollectionView()
        setupBindings()
        setupSearchActions()
        setupEmptyState()

        if let genre = preselectedGenre {
            triggerGenreSearch(genre)
        }
    }

    private func triggerGenreSearch(_ genre: String) {
        isSearching = true
        searchBarView.setText(genre)
        collectionView?.setCollectionViewLayout(createLayout(), animated: false)
        viewModel.search(query: genre)
        updateEmptyState()
        collectionView?.reloadData()
    }
}

// MARK: - Setup

private extension SearchViewController {

    func setupBindings() {
        viewModel.onDataUpdated = { [weak self] in
            guard let self else { return }
            self.updateEmptyState()
            self.collectionView.reloadData()
        }
    }

    func setupEmptyState() {
        view.addSubview(emptyLabel)
        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    func updateEmptyState() {
        emptyLabel.isHidden = !(isSearching && viewModel.books.isEmpty && !viewModel.isLoading)
    }

    func setupSearchBar() {
        view.addSubview(searchBarView)
        searchBarView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchBarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchBarView.heightAnchor.constraint(equalToConstant: 70)
        ])
    }

    func setupCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.keyboardDismissMode = .onDrag

        // Home state cells
        collectionView.register(RecentSearchCell.self,     forCellWithReuseIdentifier: RecentSearchCell.identifier)
        collectionView.register(TrendingCategoryCell.self, forCellWithReuseIdentifier: TrendingCategoryCell.identifier)
        collectionView.register(TrendingBookCell.self,     forCellWithReuseIdentifier: TrendingBookCell.identifier)

        // Search result cells
        collectionView.register(TopResultCell.self,        forCellWithReuseIdentifier: TopResultCell.identifier)
        collectionView.register(OtherVersionCell.self,     forCellWithReuseIdentifier: OtherVersionCell.identifier)
        collectionView.register(RelatedAuthorCell.self,    forCellWithReuseIdentifier: RelatedAuthorCell.identifier)

        // Header
        collectionView.register(
            SearchSectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SearchSectionHeaderView.identifier
        )

        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: searchBarView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func setupSearchActions() {
        searchBarView.onSearch = { [weak self] query in
            guard let self else { return }
            self.performSearch(query)
        }

        searchBarView.onTextChange = { [weak self] text in
            guard let self else { return }
            if text.isEmpty {
                self.resetToHomeState()
            }
        }

        searchBarView.onCancel = { [weak self] in
            self?.resetToHomeState()
        }
    }

    func makeBookDetail(book: Audiobook) -> BookDetailViewController {
        guard let fvm = favoritesViewModel else {
            // Fallback — coordinator olmadan açılırsa
            fatalError("favoritesViewModel inject edilməyib")
        }
        return BookDetailViewController(book: book, favoritesViewModel: fvm)
    }

    func resetToHomeState() {
        isSearching = false
        preselectedGenre = nil
        searchBarView.resetToHome()
        collectionView.setCollectionViewLayout(createLayout(), animated: false)
        collectionView.reloadData()
        updateEmptyState()
    }

    func performSearch(_ query: String) {
        guard !query.isEmpty else { return }
        isSearching = true
        searchBarView.setText(query)
        viewModel.search(query: query)
        collectionView.setCollectionViewLayout(createLayout(), animated: false)
        updateEmptyState()
        collectionView.reloadData()
    }
}

// MARK: - DataSource

extension SearchViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        isSearching ? 3 : 3
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        if !isSearching {
            switch HomeSection(rawValue: section) {
            case .recents:      return recentSearches.count
            case .trending:     return trendingCategories.count
            case .youMightLike: return viewModel.youMightLike.count
            case .none:         return 0
            }
        }
        // Searching state
        switch section {
        case 0: return viewModel.topResult == nil ? 0 : 1
        case 1: return viewModel.otherVersions.count
        default: return viewModel.relatedAuthors.count
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if !isSearching {
            switch HomeSection(rawValue: indexPath.section) {
            case .recents:
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: RecentSearchCell.identifier, for: indexPath
                ) as! RecentSearchCell
                cell.configure(with: recentSearches[indexPath.item])
                cell.onDelete = { [weak self] in
                    guard let self else { return }
                    self.viewModel.deleteRecent(at: indexPath.item)
                }
                return cell

            case .trending:
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: TrendingCategoryCell.identifier, for: indexPath
                ) as! TrendingCategoryCell
                cell.configure(with: trendingCategories[indexPath.item])
                return cell

            case .youMightLike:
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: TrendingBookCell.identifier, for: indexPath
                ) as! TrendingBookCell
                cell.configure(with: viewModel.youMightLike[indexPath.item])
                return cell

            case .none:
                return UICollectionViewCell()
            }
        }

        // Searching state
        switch indexPath.section {
        case 0:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: TopResultCell.identifier, for: indexPath
            ) as! TopResultCell
            if let book = viewModel.topResult {
                cell.configure(with: book)
                cell.onListen = { [weak self] in
                    guard let self else { return }
                    self.navigationController?.pushViewController(
                        self.makeBookDetail(book: book), animated: true
                    )
                }
            }
            return cell

        case 1:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: OtherVersionCell.identifier, for: indexPath
            ) as! OtherVersionCell
            cell.configure(with: viewModel.otherVersions[indexPath.item])
            return cell

        default:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: RelatedAuthorCell.identifier, for: indexPath
            ) as! RelatedAuthorCell
            cell.configure(with: viewModel.relatedAuthors[indexPath.item])
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }

        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: SearchSectionHeaderView.identifier,
            for: indexPath
        ) as! SearchSectionHeaderView

        if !isSearching {
            switch HomeSection(rawValue: indexPath.section) {
            case .recents:
                header.configure("Recent Searches", showClearAll: !recentSearches.isEmpty)
                header.onClearAll = { [weak self] in
                    self?.viewModel.clearRecents()
                }
            case .trending:
                header.configure("Trending Categories")
            case .youMightLike:
                header.configure("You Might Like")
            case .none:
                break
            }
        } else {
            switch indexPath.section {
            case 0:  header.configure("Top Result")
            case 1:  header.configure("Other Results")
            default: header.configure("Authors")
            }
        }

        return header
    }
}

// MARK: - Delegate

extension SearchViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        if !isSearching {
            switch HomeSection(rawValue: indexPath.section) {
            case .recents:
                let query = recentSearches[indexPath.item]
                searchBarView.onSearch?(query)

            case .trending:
                let category = trendingCategories[indexPath.item]
                isSearching = true
                searchBarView.setText(category.title)
                viewModel.searchByGenre(subject: category.subject, displayTitle: category.title)
                collectionView.setCollectionViewLayout(createLayout(), animated: false)
                updateEmptyState()
                collectionView.reloadData()

            case .youMightLike:
                let book = viewModel.youMightLike[indexPath.item]
                navigationController?.pushViewController(
                    makeBookDetail(book: book), animated: true
                )

            case .none:
                break
            }
            return
        }

        // Searching state
        switch indexPath.section {
        case 0:
            if let book = viewModel.topResult {
                navigationController?.pushViewController(
                    makeBookDetail(book: book), animated: true
                )
            }
        case 1:
            let book = viewModel.otherVersions[indexPath.item]
            navigationController?.pushViewController(
                makeBookDetail(book: book), animated: true
            )
        default:
            break
        }
    }
}

// MARK: - Layout

private extension SearchViewController {

    func makeHeader(height: CGFloat = 50) -> NSCollectionLayoutBoundarySupplementaryItem {
        NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(height)),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
    }

    func createLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
            guard let self else { return nil }

            if self.isSearching {
                switch sectionIndex {
                case 0:
                    let s = self.topResultSection()
                    s.boundarySupplementaryItems = [self.makeHeader()]
                    return s
                case 1:
                    let s = self.otherVersionsSection()
                    s.boundarySupplementaryItems = [self.makeHeader()]
                    return s
                default:
                    let s = self.relatedAuthorsSection()
                    s.boundarySupplementaryItems = [self.makeHeader()]
                    return s
                }
            } else {
                switch HomeSection(rawValue: sectionIndex) {
                case .recents:
                    let s = self.recentSection()
                    s.boundarySupplementaryItems = [self.makeHeader()]
                    return s
                case .trending:
                    let s = self.trendingSection()
                    s.boundarySupplementaryItems = [self.makeHeader()]
                    return s
                case .youMightLike:
                    let s = self.youMightLikeSection()
                    s.boundarySupplementaryItems = [self.makeHeader()]
                    return s
                case .none:
                    return nil
                }
            }
        }
    }

    // MARK: Home Sections

    func recentSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50))
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: item.layoutSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10
        section.contentInsets = .init(top: 10, leading: 20, bottom: 24, trailing: 20)
        return section
    }

    func trendingSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: .init(widthDimension: .fractionalWidth(0.5), heightDimension: .absolute(110))
        )
        item.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 8)

        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(110)),
            subitems: [item, item]
        )

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 12
        section.contentInsets = .init(top: 10, leading: 20, bottom: 28, trailing: 12)
        return section
    }

    func youMightLikeSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: .init(widthDimension: .absolute(140), heightDimension: .absolute(230))
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(widthDimension: .absolute(140), heightDimension: .absolute(230)),
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 16
        section.contentInsets = .init(top: 10, leading: 20, bottom: 40, trailing: 20)
        return section
    }

    // MARK: Search Sections

    func topResultSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(170))
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: item.layoutSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 10, leading: 20, bottom: 20, trailing: 20)
        return section
    }

    func otherVersionsSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(80))
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: item.layoutSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 14
        section.contentInsets = .init(top: 10, leading: 20, bottom: 20, trailing: 20)
        return section
    }

    func relatedAuthorsSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: .init(widthDimension: .absolute(90), heightDimension: .absolute(120))
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(widthDimension: .absolute(90), heightDimension: .absolute(120)),
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 16
        section.contentInsets = .init(top: 10, leading: 20, bottom: 40, trailing: 20)
        return section
    }
}
