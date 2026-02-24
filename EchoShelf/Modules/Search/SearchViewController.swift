//
//  Search.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 21.02.26.
import UIKit

final class SearchViewController: UIViewController {

    private var collectionView: UICollectionView!
    private let searchBarView = SearchBarView()
    private let viewModel = SearchViewModel()

    private var isSearching = false
    private let filters = ["Audiobooks","Authors","Genres","Series"]

    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No results found"
        label.textColor = UIColor.white.withAlphaComponent(0.6)
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.isHidden = true
        return label
    }()

    private var recentSearches: [String] {
        viewModel.recentSearches
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "AppBackground")
        setupSearchBar()
        setupCollectionView()
        setupBindings()
        setupSearchActions()
        setupEmptyState()
    }
}

private extension SearchViewController {

    func setupEmptyState() {
        view.addSubview(emptyLabel)
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    func updateEmptyState() {
        emptyLabel.isHidden = !(isSearching && viewModel.books.isEmpty)
    }

    func setupBindings() {
        viewModel.onDataUpdated = { [weak self] in
            self?.updateEmptyState()
            self?.collectionView.reloadData()
        }
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

        collectionView.register(FilterChipCell.self, forCellWithReuseIdentifier: "FilterChipCell")
        collectionView.register(RecentSearchCell.self, forCellWithReuseIdentifier: RecentSearchCell.identifier)
        collectionView.register(TopResultCell.self, forCellWithReuseIdentifier: TopResultCell.identifier)
        collectionView.register(OtherVersionCell.self, forCellWithReuseIdentifier: OtherVersionCell.identifier)
        collectionView.register(RelatedAuthorCell.self, forCellWithReuseIdentifier: RelatedAuthorCell.identifier)
        collectionView.register(SearchSectionHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: SearchSectionHeaderView.identifier)

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

            if query.isEmpty {
                self.isSearching = false
            } else {
                self.isSearching = true
                self.viewModel.search(query: query)
            }

            self.updateEmptyState()
            self.collectionView.setCollectionViewLayout(self.createLayout(), animated: false)
            self.collectionView.reloadData()
        }
    }

    func titleForSection(_ section: Int) -> String? {
        if !isSearching { return nil }
        switch section {
        case 0: return "Top Result"
        case 1: return "Other Results"
        default: return "Authors"
        }
    }
}

extension SearchViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        isSearching ? 3 : 2
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {

        if !isSearching {
            return section == 0 ? filters.count : recentSearches.count
        }

        switch section {
        case 0: return viewModel.topResult == nil ? 0 : 1
        case 1: return viewModel.otherVersions.count
        default: return viewModel.relatedAuthors.count
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if !isSearching {
            if indexPath.section == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterChipCell", for: indexPath) as! FilterChipCell
                cell.configure(filters[indexPath.item])
                return cell
            }

            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecentSearchCell.identifier, for: indexPath) as! RecentSearchCell
            cell.configure(with: recentSearches[indexPath.item])
            return cell
        }

        switch indexPath.section {

        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TopResultCell.identifier, for: indexPath) as! TopResultCell
            if let book = viewModel.topResult { cell.configure(with: book) }
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
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {

        guard isSearching,
              kind == UICollectionView.elementKindSectionHeader,
              let title = titleForSection(indexPath.section) else {
            return UICollectionReusableView()
        }

        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: SearchSectionHeaderView.identifier,
            for: indexPath
        ) as! SearchSectionHeaderView

        header.configure(title)
        return header
    }
}

extension SearchViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard isSearching else { return }

        if indexPath.section == 0, let book = viewModel.topResult {
            navigationController?.pushViewController(BookDetailViewController(book: book), animated: true)
        }

        if indexPath.section == 1 {
            let book = viewModel.otherVersions[indexPath.item]
            navigationController?.pushViewController(BookDetailViewController(book: book), animated: true)
        }
    }
}

private extension SearchViewController {

    func makeHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: .init(widthDimension: .fractionalWidth(1),
                              heightDimension: .absolute(40)),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
    }

    func createLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { sectionIndex, _ in
            if self.isSearching {
                switch sectionIndex {
                case 0:
                    let s = self.topResultSection(); s.boundarySupplementaryItems = [self.makeHeader()]; return s
                case 1:
                    let s = self.otherVersionsSection(); s.boundarySupplementaryItems = [self.makeHeader()]; return s
                default:
                    let s = self.relatedAuthorsSection(); s.boundarySupplementaryItems = [self.makeHeader()]; return s
                }
            } else {
                return sectionIndex == 0 ? self.filtersSection() : self.recentSection()
            }
        }
    }

    func filtersSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .estimated(80), heightDimension: .absolute(36)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .estimated(80), heightDimension: .absolute(36)), subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 12
        section.contentInsets = .init(top: 10, leading: 20, bottom: 20, trailing: 20)
        return section
    }

    func recentSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50)))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: item.layoutSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 12
        section.contentInsets = .init(top: 10, leading: 20, bottom: 30, trailing: 20)
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
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(80)))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: item.layoutSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 14
        section.contentInsets = .init(top: 10, leading: 20, bottom: 20, trailing: 20)
        return section
    }

    func relatedAuthorsSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .absolute(90), heightDimension: .absolute(120)))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .absolute(90), heightDimension: .absolute(120)), subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 16
        section.contentInsets = .init(top: 10, leading: 20, bottom: 40, trailing: 20)
        return section
    }
}
