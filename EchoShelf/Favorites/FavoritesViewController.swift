//
//  FavoritesViewController.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 01.03.26.
//
import UIKit

final class FavoritesViewController: UIViewController {

    // MARK: - ViewModel

    private let viewModel = FavoritesViewModel()

    // MARK: - UI

    private var collectionView: UICollectionView!

    private let headerLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Favorites"
        lbl.font = .systemFont(ofSize: 28, weight: .bold)
        lbl.textColor = .white
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let segmentControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: FavoriteSection.allCases.map { $0.title })
        sc.selectedSegmentIndex = 0
        sc.selectedSegmentTintColor = .systemPurple
        sc.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        sc.setTitleTextAttributes([.foregroundColor: UIColor.white.withAlphaComponent(0.5)], for: .normal)
        sc.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc
    }()

    private let emptyView = FavoritesEmptyView()

    private var selectedSection: FavoriteSection = .books {
        didSet {
            collectionView.setCollectionViewLayout(createLayout(), animated: false)
            collectionView.reloadData()
            updateEmptyState()
        }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "AppBackground")
        setupHeader()
        setupSegment()
        setupCollectionView()
        setupEmptyView()
        setupBindings()
        updateEmptyState()
    }
}

// MARK: - Setup

private extension FavoritesViewController {

    func setupBindings() {
        viewModel.onDataUpdated = { [weak self] in
            guard let self else { return }
            self.collectionView.reloadData()
            self.updateEmptyState()
        }
    }

    func setupHeader() {
        view.addSubview(headerLabel)
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            headerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        ])
    }

    func setupSegment() {
        view.addSubview(segmentControl)
        NSLayoutConstraint.activate([
            segmentControl.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 16),
            segmentControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            segmentControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            segmentControl.heightAnchor.constraint(equalToConstant: 36)
        ])
        segmentControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
    }

    func setupCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        collectionView.register(FavoriteBookCell.self,   forCellWithReuseIdentifier: FavoriteBookCell.identifier)
        collectionView.register(FavoriteAuthorCell.self, forCellWithReuseIdentifier: FavoriteAuthorCell.identifier)
        collectionView.register(FavoriteGenreCell.self,  forCellWithReuseIdentifier: FavoriteGenreCell.identifier)

        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func setupEmptyView() {
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyView)
        NSLayoutConstraint.activate([
            emptyView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 40)
        ])
    }

    func updateEmptyState() {
        let isEmpty = viewModel.isEmpty(for: selectedSection)
        emptyView.isHidden = !isEmpty
        collectionView.isHidden = isEmpty
    }

    @objc func segmentChanged() {
        selectedSection = FavoriteSection(rawValue: segmentControl.selectedSegmentIndex) ?? .books
    }
}

// MARK: - Layout

private extension FavoritesViewController {

    func createLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { [weak self] _, _ in
            guard let self else { return nil }
            switch self.selectedSection {
            case .books, .audiobooks: return self.bookGridSection()
            case .authors:            return self.authorListSection()
            case .genres:             return self.genreGridSection()
            }
        }
    }

    func bookGridSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: .init(widthDimension: .fractionalWidth(0.5), heightDimension: .absolute(220))
        )
        item.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 10)
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(220)),
            subitems: [item, item]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 16
        section.contentInsets = .init(top: 10, leading: 20, bottom: 40, trailing: 10)
        return section
    }

    func authorListSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(70))
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: item.layoutSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 12
        section.contentInsets = .init(top: 10, leading: 20, bottom: 40, trailing: 20)
        return section
    }

    func genreGridSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: .init(widthDimension: .fractionalWidth(0.5), heightDimension: .absolute(90))
        )
        item.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 10)
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(90)),
            subitems: [item, item]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 12
        section.contentInsets = .init(top: 10, leading: 20, bottom: 40, trailing: 10)
        return section
    }
}

// MARK: - DataSource

extension FavoritesViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        viewModel.items(for: selectedSection)
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch selectedSection {
        case .books:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: FavoriteBookCell.identifier, for: indexPath
            ) as! FavoriteBookCell
            cell.configure(with: viewModel.favoriteBooks[indexPath.item])
            return cell

        case .audiobooks:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: FavoriteBookCell.identifier, for: indexPath
            ) as! FavoriteBookCell
            cell.configure(with: viewModel.favoriteAudiobooks[indexPath.item])
            return cell

        case .authors:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: FavoriteAuthorCell.identifier, for: indexPath
            ) as! FavoriteAuthorCell
            cell.configure(with: viewModel.favoriteAuthors[indexPath.item])
            return cell

        case .genres:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: FavoriteGenreCell.identifier, for: indexPath
            ) as! FavoriteGenreCell
            cell.configure(with: viewModel.favoriteGenres[indexPath.item])
            return cell
        }
    }
}

// MARK: - Delegate

extension FavoritesViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        switch selectedSection {
        case .books:
            let book = viewModel.favoriteBooks[indexPath.item]
            navigationController?.pushViewController(BookDetailViewController(book: book), animated: true)
        case .audiobooks:
            let book = viewModel.favoriteAudiobooks[indexPath.item]
            navigationController?.pushViewController(BookDetailViewController(book: book), animated: true)
        default:
            break
        }
    }
}

// MARK: - Empty View

final class FavoritesEmptyView: UIView {

    init() {
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        let iconView = UIImageView(image: UIImage(systemName: "heart.slash"))
        iconView.tintColor = UIColor.white.withAlphaComponent(0.2)
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = "No favorites yet"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor.white.withAlphaComponent(0.4)
        label.translatesAutoresizingMaskIntoConstraints = false

        let subLabel = UILabel()
        subLabel.text = "Items you favorite will appear here"
        subLabel.font = .systemFont(ofSize: 13)
        subLabel.textColor = UIColor.white.withAlphaComponent(0.25)
        subLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(iconView)
        addSubview(label)
        addSubview(subLabel)

        NSLayoutConstraint.activate([
            iconView.topAnchor.constraint(equalTo: topAnchor),
            iconView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 60),
            iconView.heightAnchor.constraint(equalToConstant: 60),

            label.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 16),
            label.centerXAnchor.constraint(equalTo: centerXAnchor),

            subLabel.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 6),
            subLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            subLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
