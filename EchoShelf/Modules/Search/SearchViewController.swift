//
//  SearchViewController.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 21.02.26.
//
import UIKit

final class SearchViewController: UIViewController {

    weak var coordinator: HomeCoordinator?

    var preselectedGenre: String? {
        didSet {
            guard let genre = preselectedGenre, isViewLoaded else { return }
            triggerGenreSearch(genre)
        }
    }

    private var selectedTab: SearchTab = .audiobooks {
        didSet {
            guard selectedTab != oldValue else { return }
            updateTabIndicator()
            resetToHomeState()
        }
    }
    private var isSearching = false

    private let viewModel = SearchViewModel()

    private let trendingCategories: [TrendingCategory] = [
        TrendingCategory(title: "AI Picks",    icon: "🤖", colorName: "TrendingAIPicks",    query: "science",         subject: "Science Fiction"),
        TrendingCategory(title: "Bestsellers", icon: "🔥", colorName: "TrendingBestsellers", query: "adventure",       subject: "Adventure"),
        TrendingCategory(title: "Sci-Fi",      icon: "🚀", colorName: "TrendingSciFi",       query: "science fiction", subject: "Science Fiction"),
        TrendingCategory(title: "Thriller",    icon: "👁",  colorName: "TrendingThriller",    query: "mystery",         subject: "Mystery & Detective Stories"),
        TrendingCategory(title: "Classics",    icon: "📖", colorName: "TrendingClassics",    query: "classic",         subject: "General Fiction"),
        TrendingCategory(title: "Narrators",   icon: "🎙", colorName: "TrendingNarrators",   query: "drama",           subject: "Plays")
    ]

    private var recentSearches: [String] { viewModel.recentSearches }
    private var collectionView: UICollectionView!
    private let searchBarView = SearchBarView()

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

    private let kidsTabBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Kids", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        btn.tintColor = UIColor.white.withAlphaComponent(0.5)
        btn.tag = 2
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private var indicatorLeading: NSLayoutConstraint!

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

    private enum HomeSection: Int, CaseIterable {
        case recents      = 0
        case trending     = 1
        case youMightLike = 2
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "AppBackground")
        setupSearchBar()
        setupTabBar()
        setupCollectionView()
        setupBindings()
        setupSearchActions()
        setupEmptyState()

        if let genre = preselectedGenre {
            triggerGenreSearch(genre)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}

private extension SearchViewController {

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

    func setupTabBar() {
        view.addSubview(tabContainer)
        tabContainer.addSubview(tabIndicator)
        tabContainer.addSubview(audiobooksTabBtn)
        tabContainer.addSubview(booksTabBtn)
        tabContainer.addSubview(kidsTabBtn)

        indicatorLeading = tabIndicator.leadingAnchor.constraint(
            equalTo: tabContainer.leadingAnchor,
            constant: 3
        )

        NSLayoutConstraint.activate([
            tabContainer.topAnchor.constraint(equalTo: searchBarView.bottomAnchor, constant: 4),
            tabContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tabContainer.widthAnchor.constraint(equalToConstant: 300),
            tabContainer.heightAnchor.constraint(equalToConstant: 36),

            audiobooksTabBtn.leadingAnchor.constraint(equalTo: tabContainer.leadingAnchor),
            audiobooksTabBtn.topAnchor.constraint(equalTo: tabContainer.topAnchor),
            audiobooksTabBtn.bottomAnchor.constraint(equalTo: tabContainer.bottomAnchor),
            audiobooksTabBtn.widthAnchor.constraint(equalTo: tabContainer.widthAnchor, multiplier: 1.0/3.0),

            booksTabBtn.leadingAnchor.constraint(equalTo: audiobooksTabBtn.trailingAnchor),
            booksTabBtn.topAnchor.constraint(equalTo: tabContainer.topAnchor),
            booksTabBtn.bottomAnchor.constraint(equalTo: tabContainer.bottomAnchor),
            booksTabBtn.widthAnchor.constraint(equalTo: tabContainer.widthAnchor, multiplier: 1.0/3.0),

            kidsTabBtn.leadingAnchor.constraint(equalTo: booksTabBtn.trailingAnchor),
            kidsTabBtn.topAnchor.constraint(equalTo: tabContainer.topAnchor),
            kidsTabBtn.bottomAnchor.constraint(equalTo: tabContainer.bottomAnchor),
            kidsTabBtn.trailingAnchor.constraint(equalTo: tabContainer.trailingAnchor),

            tabIndicator.topAnchor.constraint(equalTo: tabContainer.topAnchor, constant: 3),
            tabIndicator.bottomAnchor.constraint(equalTo: tabContainer.bottomAnchor, constant: -3),
            tabIndicator.widthAnchor.constraint(equalTo: tabContainer.widthAnchor, multiplier: 1.0/3.0, constant: -3),

            indicatorLeading
        ])

        audiobooksTabBtn.addTarget(self, action: #selector(tabTapped(_:)), for: .touchUpInside)
        booksTabBtn.addTarget(self, action: #selector(tabTapped(_:)), for: .touchUpInside)
        kidsTabBtn.addTarget(self, action: #selector(tabTapped(_:)), for: .touchUpInside)
    }

    func setupCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.keyboardDismissMode = .onDrag
        collectionView.showsVerticalScrollIndicator = false

        collectionView.register(RecentSearchCell.self,      forCellWithReuseIdentifier: RecentSearchCell.identifier)
        collectionView.register(TrendingCategoryCell.self,  forCellWithReuseIdentifier: TrendingCategoryCell.identifier)
        collectionView.register(TrendingBookCell.self,      forCellWithReuseIdentifier: TrendingBookCell.identifier)
        collectionView.register(TopResultCell.self,         forCellWithReuseIdentifier: TopResultCell.identifier)
        collectionView.register(OtherVersionCell.self,      forCellWithReuseIdentifier: OtherVersionCell.identifier)
        collectionView.register(RelatedAuthorCell.self,     forCellWithReuseIdentifier: RelatedAuthorCell.identifier)
        collectionView.register(EbookTopResultCell.self,    forCellWithReuseIdentifier: EbookTopResultCell.identifier)
        collectionView.register(EbookOtherResultCell.self,  forCellWithReuseIdentifier: EbookOtherResultCell.identifier)
        collectionView.register(EbookYouMightLikeCell.self, forCellWithReuseIdentifier: EbookYouMightLikeCell.identifier)
        collectionView.register(KidsTrendingCell.self,      forCellWithReuseIdentifier: KidsTrendingCell.identifier)
        collectionView.register(KidsRecommendedCell.self,   forCellWithReuseIdentifier: KidsRecommendedCell.identifier)

        collectionView.register(
            SearchSectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SearchSectionHeaderView.identifier
        )

        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: tabContainer.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func setupBindings() {
        viewModel.onDataUpdated = { [weak self] in
            guard let self else { return }
            self.updateEmptyState()
            self.collectionView.reloadData()
        }
    }

    func setupSearchActions() {
        searchBarView.onSearch = { [weak self] query in
            self?.performSearch(query)
        }
        searchBarView.onTextChange = { [weak self] text in
            if text.isEmpty { self?.resetToHomeState() }
        }
        searchBarView.onCancel = { [weak self] in
            self?.resetToHomeState()
        }
    }

    func setupEmptyState() {
        view.addSubview(emptyLabel)
        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    func updateTabIndicator() {
        let tabW = tabContainer.bounds.width / 3
        let offset: CGFloat
        switch selectedTab {
        case .audiobooks: offset = 3
        case .books:      offset = tabW
        case .kids:       offset = tabW * 2
        }
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
            self.indicatorLeading.constant = offset
            self.tabContainer.layoutIfNeeded()
        }
        audiobooksTabBtn.tintColor = selectedTab == .audiobooks ? .white : UIColor.white.withAlphaComponent(0.5)
        booksTabBtn.tintColor      = selectedTab == .books       ? .white : UIColor.white.withAlphaComponent(0.5)
        kidsTabBtn.tintColor       = selectedTab == .kids        ? .white : UIColor.white.withAlphaComponent(0.5)
    }

    func updateEmptyState() {
        let isEmpty: Bool
        switch selectedTab {
        case .audiobooks: isEmpty = viewModel.books.isEmpty
        case .books:      isEmpty = viewModel.ebooks.isEmpty
        case .kids:       isEmpty = viewModel.kidsBooks.isEmpty
        }
        emptyLabel.isHidden = !(isSearching && isEmpty && !viewModel.isLoading)
    }

    func triggerGenreSearch(_ genre: String) {
        isSearching = true
        searchBarView.setText(genre)
        collectionView.setCollectionViewLayout(createLayout(), animated: false)
        viewModel.searchByGenre(subject: genre, displayTitle: genre, tab: selectedTab)
        updateEmptyState()
        collectionView.reloadData()
    }

    func performSearch(_ query: String) {
        guard !query.isEmpty else { return }
        isSearching = true
        searchBarView.setText(query)
        viewModel.search(query: query, tab: selectedTab)
        collectionView.setCollectionViewLayout(createLayout(), animated: false)
        updateEmptyState()
        collectionView.reloadData()
    }

    func resetToHomeState() {
        isSearching = false
        preselectedGenre = nil
        searchBarView.resetToHome()
        collectionView.setCollectionViewLayout(createLayout(), animated: false)
        collectionView.reloadData()
        updateEmptyState()
    }

    func openAudiobookDetail(_ book: Audiobook) {
        navigationController?.pushViewController(
            BookDetailViewController(book: book), animated: true
        )
    }

    func openEbookDetail(_ ebook: Ebook) {
        navigationController?.pushViewController(
            BookDetailViewController(ebook: ebook), animated: true
        )
    }

    @objc func tabTapped(_ sender: UIButton) {
        let newTab: SearchTab
        switch sender.tag {
        case 1:  newTab = .books
        case 2:  newTab = .kids
        default: newTab = .audiobooks
        }
        guard newTab != selectedTab else { return }
        selectedTab = newTab
    }
}

extension SearchViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int { 3 }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        if !isSearching {
            switch HomeSection(rawValue: section) {
            case .recents:      return recentSearches.count
            case .trending:     return trendingCategories.count
            case .youMightLike:
                switch selectedTab {
                case .audiobooks: return viewModel.youMightLike.count
                case .books:      return viewModel.youMightLikeEbooks.count
                case .kids:       return viewModel.youMightLikeKids.count
                }
            case .none: return 0
            }
        } else {
            switch section {
            case 0:
                switch selectedTab {
                case .audiobooks: return viewModel.topResult != nil ? 1 : 0
                case .books:      return viewModel.topEbookResult != nil ? 1 : 0
                case .kids:       return viewModel.topKidsResult != nil ? 1 : 0
                }
            case 1:
                switch selectedTab {
                case .audiobooks: return viewModel.otherVersions.count
                case .books:      return viewModel.otherEbooks.count
                case .kids:       return viewModel.otherKidsBooks.count
                }
            case 2:
                return selectedTab == .audiobooks ? viewModel.relatedAuthors.count : 0
            default: return 0
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if !isSearching {
            return homeCellForItem(at: indexPath)
        } else {
            return searchCellForItem(at: indexPath)
        }
    }

    private func homeCellForItem(at indexPath: IndexPath) -> UICollectionViewCell {
        switch HomeSection(rawValue: indexPath.section) {
        case .recents:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecentSearchCell.identifier, for: indexPath) as! RecentSearchCell
            cell.configure(with: recentSearches[indexPath.item])
            cell.onDelete = { [weak self] in self?.viewModel.deleteRecent(at: indexPath.item) }
            return cell

        case .trending:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrendingCategoryCell.identifier, for: indexPath) as! TrendingCategoryCell
            cell.configure(with: trendingCategories[indexPath.item])
            return cell

        case .youMightLike:
            switch selectedTab {
            case .audiobooks:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrendingBookCell.identifier, for: indexPath) as! TrendingBookCell
                cell.configure(with: viewModel.youMightLike[indexPath.item])
                return cell
            case .books:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EbookYouMightLikeCell.identifier, for: indexPath) as! EbookYouMightLikeCell
                cell.configure(with: viewModel.youMightLikeEbooks[indexPath.item])
                return cell
            case .kids:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: KidsTrendingCell.identifier, for: indexPath) as! KidsTrendingCell
                cell.configure(with: viewModel.youMightLikeKids[indexPath.item])
                return cell
            }

        case .none:
            return UICollectionViewCell()
        }
    }

    private func searchCellForItem(at indexPath: IndexPath) -> UICollectionViewCell {
        if selectedTab == .audiobooks {
            switch indexPath.section {
            case 0:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TopResultCell.identifier, for: indexPath) as! TopResultCell
                if let book = viewModel.topResult {
                    cell.configure(with: book)
                    cell.onListen = { [weak self] in self?.openAudiobookDetail(book) }
                }
                return cell
            case 1:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OtherVersionCell.identifier, for: indexPath) as! OtherVersionCell
                cell.configure(with: viewModel.otherVersions[indexPath.item])
                return cell
            default:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RelatedAuthorCell.identifier, for: indexPath) as! RelatedAuthorCell
                cell.configure(with: viewModel.relatedAuthors[indexPath.item])
                return cell
            }
        } else {
            switch indexPath.section {
            case 0:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EbookTopResultCell.identifier, for: indexPath) as! EbookTopResultCell
                if let ebook = viewModel.topEbookResult {
                    cell.configure(with: ebook)
                    cell.onRead = { [weak self] in self?.openEbookDetail(ebook) }
                }
                return cell
            default:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EbookOtherResultCell.identifier, for: indexPath) as! EbookOtherResultCell
                cell.configure(with: viewModel.otherEbooks[indexPath.item])
                return cell
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: SearchSectionHeaderView.identifier,
            for: indexPath
        ) as! SearchSectionHeaderView

        if !isSearching {
            switch HomeSection(rawValue: indexPath.section) {
            case .recents:
                header.configure("Recent Searches", showClearAll: !recentSearches.isEmpty)
                header.onClearAll = { [weak self] in self?.viewModel.clearRecents() }
            case .trending:
                header.configure("Trending Categories")
            case .youMightLike:
                let title = selectedTab == .audiobooks ? "You Might Like" : "Popular Books"
                header.configure(title)
            case .none: break
            }
        } else {
            switch indexPath.section {
            case 0: header.configure("Top Result")
            case 1: header.configure(selectedTab == .audiobooks ? "Other Versions" : "More Books")
            default: header.configure("Authors")
            }
        }
        return header
    }
}

extension SearchViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        if !isSearching {
            switch HomeSection(rawValue: indexPath.section) {
            case .recents:
                searchBarView.onSearch?(recentSearches[indexPath.item])

            case .trending:
                let category = trendingCategories[indexPath.item]
                isSearching = true
                searchBarView.setText(category.title)
                viewModel.searchByGenre(subject: category.subject, displayTitle: category.title, tab: selectedTab)
                collectionView.setCollectionViewLayout(createLayout(), animated: false)
                updateEmptyState()
                collectionView.reloadData()

            case .youMightLike:
                switch selectedTab {
                case .audiobooks: openAudiobookDetail(viewModel.youMightLike[indexPath.item])
                case .books:      openEbookDetail(viewModel.youMightLikeEbooks[indexPath.item])
                case .kids:       openEbookDetail(viewModel.youMightLikeKids[indexPath.item])
                }

            case .none: break
            }
        } else {
            switch indexPath.section {
            case 0:
                if selectedTab == .audiobooks, let book = viewModel.topResult {
                    openAudiobookDetail(book)
                } else if let ebook = viewModel.topEbookResult {
                    openEbookDetail(ebook)
                }
            case 1:
                if selectedTab == .audiobooks {
                    openAudiobookDetail(viewModel.otherVersions[indexPath.item])
                } else {
                    openEbookDetail(viewModel.otherEbooks[indexPath.item])
                }
            default: break
            }
        }
    }
}

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
                case .none: return nil
                }
            }
        }
    }

    func recentSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50)))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: item.layoutSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10
        section.contentInsets = .init(top: 10, leading: 20, bottom: 24, trailing: 20)
        return section
    }

    func trendingSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(0.5), heightDimension: .absolute(110)))
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
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .absolute(140), heightDimension: .absolute(230)))
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

    func topResultSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(170)))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: item.layoutSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 10, leading: 20, bottom: 20, trailing: 20)
        return section
    }

    func otherVersionsSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(90)))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: item.layoutSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 12
        section.contentInsets = .init(top: 10, leading: 20, bottom: 20, trailing: 20)
        return section
    }

    func relatedAuthorsSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .absolute(90), heightDimension: .absolute(120)))
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
