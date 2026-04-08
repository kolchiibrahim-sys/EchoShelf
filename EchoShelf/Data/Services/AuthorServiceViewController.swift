//
//  AuthorsViewController.swift
//  EchoShelf
//
import UIKit

final class AuthorsViewController: UIViewController {

    private var authors: [Author] = []
    private var collectionView: UICollectionView!

    private lazy var headerLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Authors"
        lbl.font = .systemFont(ofSize: 28, weight: .bold)
        lbl.textColor = UIColor(named: "OnDarkTextPrimary")
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private lazy var emptyLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "No authors yet.\nExplore books to discover authors."
        lbl.font = .systemFont(ofSize: 15)
        lbl.textColor = UIColor(named: "OnDarkTextSecondary")
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "AppBackground")
        setupHeader()
        setupCollectionView()
        setupEmptyView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        loadAuthors()
    }

    private func loadAuthors() {
        let favVM = FavoritesViewModel()
        authors = favVM.favoriteAuthors
        collectionView.reloadData()
        emptyLabel.isHidden = !authors.isEmpty
        collectionView.isHidden = authors.isEmpty
    }

    private func setupHeader() {
        view.addSubview(headerLabel)
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            headerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        ])
    }

    private func setupCollectionView() {
        let layout = createLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(RelatedAuthorCell.self, forCellWithReuseIdentifier: RelatedAuthorCell.identifier)
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupEmptyView() {
        view.addSubview(emptyLabel)
        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func createLayout() -> UICollectionViewLayout {
        let item = NSCollectionLayoutItem(
            layoutSize: .init(widthDimension: .fractionalWidth(0.33), heightDimension: .absolute(140))
        )
        item.contentInsets = .init(top: 0, leading: 4, bottom: 0, trailing: 4)
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(140)),
            subitems: [item, item, item]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 16
        section.contentInsets = .init(top: 10, leading: 16, bottom: 40, trailing: 16)
        return UICollectionViewCompositionalLayout(section: section)
    }
}

extension AuthorsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        authors.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RelatedAuthorCell.identifier, for: indexPath) as! RelatedAuthorCell
        cell.configure(with: authors[indexPath.item])
        return cell
    }
}

extension AuthorsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let author = authors[indexPath.item]
        navigationController?.pushViewController(AuthorDetailViewController(author: author),
                                                 animated: true)
    }
}
