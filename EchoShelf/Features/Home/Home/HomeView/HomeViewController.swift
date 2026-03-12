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

    private var selectedTab: HomeTab = .audiobooks {
        didSet {
            updateTabIndicator()
            collectionView.reloadData()
        }
    }

    private lazy var greetingView: HomeHeaderCell = HomeHeaderCell()

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

    private let kidsTabButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Kids", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        btn.tintColor = UIColor.white.withAlphaComponent(0.5)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.tag = 2
        return btn
    }()

    private var indicatorLeadingConstraint: NSLayoutConstraint!

    private let genres = [
        "Fantasy", "Drama", "Romance", "Mystery",
        "Sci-Fi", "History", "Adventure", "Kids"
    ]

    private var trendingItems: Int {
        switch selectedTab {
        case .audiobooks: return viewModel.trendingAudiobooks.count
        case .books:      return viewModel.trendingEbooks.count
        case .kids:       return viewModel.trendingKidsEbooks.count
        }
    }

    private var recommendedItems: Int {
        switch selectedTab {
        case .audiobooks: return viewModel.recommendedAudiobooks.count
        case .books:      return viewModel.recommendedEbooks.count
        case .kids:       return viewModel.recommendedKidsEbooks.count
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "AppBackground")
        setupGreeting()
        setupTopTab()
        setupCollectionView()
        bindViewModel()
        viewModel.fetchBooks()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        greetingView.configure()
    }
}

private extension HomeViewController {

    func setupGreeting() {
        greetingView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(greetingView)
        NSLayoutConstraint.activate([
            greetingView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            greetingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            greetingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            greetingView.heightAnchor.constraint(equalToConstant: 60)
        ])
        greetingView.configure()
    }

    func setupTopTab() {
        view.addSubview(tabContainer)
        tabContainer.addSubview(tabIndicator)
        tabContainer.addSubview(audiobooksTabButton)
        tabContainer.addSubview(booksTabButton)
        tabContainer.addSubview(kidsTabButton)

        indicatorLeadingConstraint = tabIndicator.leadingAnchor.constraint(
            equalTo: tabContainer.leadingAnchor,
            constant: 3
        )

        NSLayoutConstraint.activate([
            tabContainer.topAnchor.constraint(equalTo: greetingView.bottomAnchor, constant: 8),
            tabContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tabContainer.widthAnchor.constraint(equalToConstant: 320),
            tabContainer.heightAnchor.constraint(equalToConstant: 40),

            audiobooksTabButton.leadingAnchor.constraint(equalTo: tabContainer.leadingAnchor),
            audiobooksTabButton.topAnchor.constraint(equalTo: tabContainer.topAnchor),
            audiobooksTabButton.bottomAnchor.constraint(equalTo: tabContainer.bottomAnchor),
            audiobooksTabButton.widthAnchor.constraint(equalTo: tabContainer.widthAnchor, multiplier: 1.0/3.0),

            booksTabButton.leadingAnchor.constraint(equalTo: audiobooksTabButton.trailingAnchor),
            booksTabButton.topAnchor.constraint(equalTo: tabContainer.topAnchor),
            booksTabButton.bottomAnchor.constraint(equalTo: tabContainer.bottomAnchor),
            booksTabButton.widthAnchor.constraint(equalTo: tabContainer.widthAnchor, multiplier: 1.0/3.0),

            kidsTabButton.leadingAnchor.constraint(equalTo: booksTabButton.trailingAnchor),
            kidsTabButton.topAnchor.constraint(equalTo: tabContainer.topAnchor),
            kidsTabButton.bottomAnchor.constraint(equalTo: tabContainer.bottomAnchor),
            kidsTabButton.trailingAnchor.constraint(equalTo: tabContainer.trailingAnchor),

            tabIndicator.topAnchor.constraint(equalTo: tabContainer.topAnchor, constant: 3),
            tabIndicator.bottomAnchor.constraint(equalTo: tabContainer.bottomAnchor, constant: -3),
            tabIndicator.widthAnchor.constraint(equalTo: tabContainer.widthAnchor, multiplier: 1.0/3.0, constant: -3),

            indicatorLeadingConstraint
        ])

        audiobooksTabButton.addTarget(self, action: #selector(tabTapped(_:)), for: .touchUpInside)
        booksTabButton.addTarget(self, action: #selector(tabTapped(_:)), for: .touchUpInside)
        kidsTabButton.addTarget(self, action: #selector(tabTapped(_:)), for: .touchUpInside)
    }

    @objc func tabTapped(_ sender: UIButton) {
        let newTab: HomeTab
        switch sender.tag {
        case 1:  newTab = .books
        case 2:  newTab = .kids
        default: newTab = .audiobooks
        }
        guard newTab != selectedTab else { return }
        selectedTab = newTab
    }

    func updateTabIndicator() {
        let tabWidth = tabContainer.bounds.width / 3
        let offset: CGFloat
        switch selectedTab {
        case .audiobooks: offset = 3
        case .books:      offset = tabWidth
        case .kids:       offset = tabWidth * 2
        }

        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
            self.indicatorLeadingConstraint.constant = offset
            self.tabContainer.layoutIfNeeded()
        }

        audiobooksTabButton.tintColor = selectedTab == .audiobooks ? .white : UIColor.white.withAlphaComponent(0.5)
        booksTabButton.tintColor      = selectedTab == .books       ? .white : UIColor.white.withAlphaComponent(0.5)
        kidsTabButton.tintColor       = selectedTab == .kids        ? .white : UIColor.white.withAlphaComponent(0.5)
    }

    func setupCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
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
        collectionView.register(KidsTrendingCell.self,        forCellWithReuseIdentifier: KidsTrendingCell.identifier)
        collectionView.register(KidsRecommendedCell.self,     forCellWithReuseIdentifier: KidsRecommendedCell.identifier)

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
        viewModel.onStateChanged = { [weak self] state in
            guard let self else { return }
            switch state {
            case .loading:
                break
            case .success:
                self.collectionView.reloadData()
            case .failure(let error):
                print("Home error:", error)
            case .idle:
                break
            }
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

extension HomeViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        HomeSection.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        switch HomeSection(rawValue: section)! {
        case .header:            return 0
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
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: HomeHeaderCell.identifier, for: indexPath
            ) as! HomeHeaderCell
            cell.configure()
            return cell

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
            switch selectedTab {
            case .audiobooks:
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: TrendingBookCell.identifier, for: indexPath
                ) as! TrendingBookCell
                cell.configure(with: viewModel.trendingAudiobooks[indexPath.item])
                return cell
            case .books:
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: EbookTrendingCell.identifier, for: indexPath
                ) as! EbookTrendingCell
                cell.configure(with: viewModel.trendingEbooks[indexPath.item])
                return cell
            case .kids:
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: KidsTrendingCell.identifier, for: indexPath
                ) as! KidsTrendingCell
                cell.configure(with: viewModel.trendingKidsEbooks[indexPath.item])
                return cell
            }

        case .recommended:
            switch selectedTab {
            case .audiobooks:
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: RecommendedBookCell.identifier, for: indexPath
                ) as! RecommendedBookCell
                cell.configure(with: viewModel.recommendedAudiobooks[indexPath.item])
                return cell
            case .books:
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: EbookRecommendedCell.identifier, for: indexPath
                ) as! EbookRecommendedCell
                cell.configure(with: viewModel.recommendedEbooks[indexPath.item])
                return cell
            case .kids:
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: KidsRecommendedCell.identifier, for: indexPath
                ) as! KidsRecommendedCell
                cell.configure(with: viewModel.recommendedKidsEbooks[indexPath.item])
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

extension HomeViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        switch HomeSection(rawValue: indexPath.section)! {

        case .trending:
            switch selectedTab {
            case .audiobooks: coordinator?.showBookDetail(book: viewModel.trendingAudiobooks[indexPath.item])
            case .books:      coordinator?.showEbookDetail(ebook: viewModel.trendingEbooks[indexPath.item])
            case .kids:       coordinator?.showEbookDetail(ebook: viewModel.trendingKidsEbooks[indexPath.item])
            }

        case .recommended:
            switch selectedTab {
            case .audiobooks: coordinator?.showBookDetail(book: viewModel.recommendedAudiobooks[indexPath.item])
            case .books:      coordinator?.showEbookDetail(ebook: viewModel.recommendedEbooks[indexPath.item])
            case .kids:       coordinator?.showEbookDetail(ebook: viewModel.recommendedKidsEbooks[indexPath.item])
            }

        case .genres:
            coordinator?.showGenreSearch(genre: genres[indexPath.item])

        default:
            break
        }
    }
}

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
            layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(40)),
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
