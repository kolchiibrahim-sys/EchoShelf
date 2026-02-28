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

    // MARK: - Coordinator
    weak var coordinator: HomeCoordinator?

    // MARK: - ViewModel
    private let viewModel = HomeViewModel()

    // MARK: - UI
    private var collectionView: UICollectionView!

    private let genres = [
        "Fantasy", "Drama", "Romance", "Mystery",
        "Sci-Fi", "History", "Adventure", "Kids"
    ]

    private var trendingBooks: [Audiobook] {
        Array(viewModel.books.prefix(10))
    }

    private var recommendedBooks: [Audiobook] {
        Array(viewModel.books.dropFirst(10).prefix(10))
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "AppBackground")
        setupCollectionView()
        bindViewModel()
        viewModel.fetchBooks()
    }
}

// MARK: - Setup
private extension HomeViewController {

    func setupCollectionView() {
        collectionView = UICollectionView(
            frame: view.bounds,
            collectionViewLayout: createLayout()
        )
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.register(HomeHeaderCell.self, forCellWithReuseIdentifier: HomeHeaderCell.identifier)
        collectionView.register(ContinueListeningCell.self, forCellWithReuseIdentifier: ContinueListeningCell.identifier)
        collectionView.register(TrendingBookCell.self, forCellWithReuseIdentifier: TrendingBookCell.identifier)
        collectionView.register(GenreCell.self, forCellWithReuseIdentifier: GenreCell.identifier)
        collectionView.register(RecommendedBookCell.self, forCellWithReuseIdentifier: RecommendedBookCell.identifier)

        collectionView.register(
            HomeSectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: HomeSectionHeaderView.identifier
        )

        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
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
        case .continueListening: return "Continue Listening"
        case .genres:            return "Genres"
        case .trending:          return "Trending Today"
        case .recommended:       return "Recommended For You"
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

// MARK: - UICollectionViewDataSource
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
        case .trending:          return trendingBooks.count
        case .recommended:       return recommendedBooks.count
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
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: TrendingBookCell.identifier, for: indexPath
            ) as! TrendingBookCell
            cell.configure(with: trendingBooks[indexPath.item])
            return cell

        case .recommended:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: RecommendedBookCell.identifier, for: indexPath
            ) as! RecommendedBookCell
            cell.configure(with: recommendedBooks[indexPath.item])
            return cell
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

// MARK: - UICollectionViewDelegate
extension HomeViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {

        switch HomeSection(rawValue: indexPath.section)! {

        case .trending:
            coordinator?.showBookDetail(book: trendingBooks[indexPath.item])

        case .recommended:
            coordinator?.showBookDetail(book: recommendedBooks[indexPath.item])

        case .genres:
            let genre = genres[indexPath.item]
            coordinator?.showGenreSearch(genre: genre)

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
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(120)))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: item.layoutSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 60, leading: 20, bottom: 0, trailing: 20)
        return section
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
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .absolute(150), heightDimension: .absolute(220)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .absolute(150), heightDimension: .absolute(220)), subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 16
        section.contentInsets = .init(top: 30, leading: 20, bottom: 0, trailing: 20)
        section.boundarySupplementaryItems = [makeHeader()]
        return section
    }

    func recommendedSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(120)))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: item.layoutSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 16
        section.contentInsets = .init(top: 30, leading: 20, bottom: 40, trailing: 20)
        section.boundarySupplementaryItems = [makeHeader()]
        return section
    }
}
