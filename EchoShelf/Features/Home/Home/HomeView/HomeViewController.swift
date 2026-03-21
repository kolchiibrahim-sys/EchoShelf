//
//  HomeViewController.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 21.02.26.
//
import UIKit

enum HomeSection: Int, CaseIterable {
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
            updateSegment()
            collectionView.reloadData()
        }
    }

    private lazy var greetingView: HomeHeaderCell = {
        let v = HomeHeaderCell()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private lazy var segmentControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Audiobooks", "Books", "Kids", "Genres"])
        sc.selectedSegmentIndex = 0
        sc.selectedSegmentTintColor = .systemPurple
        sc.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        sc.setTitleTextAttributes([.foregroundColor: UIColor.white.withAlphaComponent(0.6)], for: .normal)
        sc.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc
    }()
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
        setupSegmentControl()
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
        view.addSubview(greetingView)
        NSLayoutConstraint.activate([
            greetingView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            greetingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            greetingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            greetingView.heightAnchor.constraint(equalToConstant: 60)
        ])
        greetingView.configure()
    }

    func setupSegmentControl() {
        view.addSubview(segmentControl)
        NSLayoutConstraint.activate([
            segmentControl.topAnchor.constraint(equalTo: greetingView.bottomAnchor, constant: 12),
            segmentControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            segmentControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            segmentControl.heightAnchor.constraint(equalToConstant: 36)
        ])
        segmentControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
    }

    @objc func segmentChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 1:  selectedTab = .books
        case 2:  selectedTab = .kids
        default: selectedTab = .audiobooks
        }
    }

    func updateSegment() {
        switch selectedTab {
        case .audiobooks: segmentControl.selectedSegmentIndex = 0
        case .books:      segmentControl.selectedSegmentIndex = 1
        case .kids:       segmentControl.selectedSegmentIndex = 2
        }
    }

    func setupCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = false

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
            collectionView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func bindViewModel() {
        viewModel.onStateChanged = { [weak self] state in
            guard let self else { return }
            if case .success = state { self.collectionView.reloadData() }
        }
    }

    func titleForSection(_ section: HomeSection) -> String {
        switch section {
        case .continueListening: return selectedTab == .audiobooks ? "Continue Listening" : "Continue Reading"
        case .genres:            return "Genres"
        case .trending:          return selectedTab == .audiobooks ? "Trending Audiobooks" : "Trending Books"
        case .recommended:       return selectedTab == .audiobooks ? "Recommended For You" : "You Might Like"
        }
    }
}

extension HomeViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        HomeSection.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch HomeSection(rawValue: section)! {
        case .continueListening: return 1
        case .genres:            return genres.count
        case .trending:          return trendingItems
        case .recommended:       return recommendedItems
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch HomeSection(rawValue: indexPath.section)! {

        case .continueListening:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ContinueListeningCell.identifier, for: indexPath) as! ContinueListeningCell
            cell.configure()
            return cell

        case .genres:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GenreCell.identifier, for: indexPath) as! GenreCell
            cell.configure(genres[indexPath.item])
            return cell

        case .trending:
            switch selectedTab {
            case .audiobooks:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrendingBookCell.identifier, for: indexPath) as! TrendingBookCell
                cell.configure(with: viewModel.trendingAudiobooks[indexPath.item])
                return cell
            case .books:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EbookTrendingCell.identifier, for: indexPath) as! EbookTrendingCell
                cell.configure(with: viewModel.trendingEbooks[indexPath.item])
                return cell
            case .kids:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: KidsTrendingCell.identifier, for: indexPath) as! KidsTrendingCell
                cell.configure(with: viewModel.trendingKidsEbooks[indexPath.item])
                return cell
            }

        case .recommended:
            switch selectedTab {
            case .audiobooks:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecommendedBookCell.identifier, for: indexPath) as! RecommendedBookCell
                cell.configure(with: viewModel.recommendedAudiobooks[indexPath.item])
                return cell
            case .books:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EbookRecommendedCell.identifier, for: indexPath) as! EbookRecommendedCell
                cell.configure(with: viewModel.recommendedEbooks[indexPath.item])
                return cell
            case .kids:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: KidsRecommendedCell.identifier, for: indexPath) as! KidsRecommendedCell
                cell.configure(with: viewModel.recommendedKidsEbooks[indexPath.item])
                return cell
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else { return UICollectionReusableView() }
        let section = HomeSection(rawValue: indexPath.section)!
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: HomeSectionHeaderView.identifier,
            for: indexPath
        ) as! HomeSectionHeaderView
        let showViewAll = section == .trending || section == .recommended
        header.configure(titleForSection(section), showViewAll: showViewAll)
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

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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

    func continueSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(120)))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: item.layoutSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 10, leading: 20, bottom: 0, trailing: 20)
        section.boundarySupplementaryItems = [makeHeader()]
        return section
    }

    func genresSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .absolute(100), heightDimension: .absolute(36)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .estimated(100), heightDimension: .absolute(36)), subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 12
        section.contentInsets = .init(top: 20, leading: 20, bottom: 0, trailing: 20)
        section.boundarySupplementaryItems = [makeHeader()]
        return section
    }

    func trendingSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .absolute(150), heightDimension: .absolute(240)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .absolute(150), heightDimension: .absolute(240)), subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 16
        section.contentInsets = .init(top: 12, leading: 20, bottom: 8, trailing: 20)
        section.boundarySupplementaryItems = [makeHeader()]
        return section
    }

    func recommendedSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(116)))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: item.layoutSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 12
        section.contentInsets = .init(top: 12, leading: 20, bottom: 40, trailing: 20)
        section.boundarySupplementaryItems = [makeHeader()]
        return section
    }
}
