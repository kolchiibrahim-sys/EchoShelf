//
//  AuthorsViewController.swift
//  EchoShelf
//
import UIKit

final class AuthorsViewController: UIViewController {

    private let service = AuthorService.shared
    private var authors: [Author] = []
    private var currentPage = 0
    private var isLoading = false
    private var hasMore = true
    private var isSearching = false
    private var collectionView: UICollectionView!

    private lazy var headerLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Authors"
        lbl.font = .systemFont(ofSize: 28, weight: .bold)
        lbl.textColor = UIColor(named: "OnDarkTextPrimary")
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private lazy var searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Search authors..."
        sb.searchBarStyle = .minimal
        sb.tintColor = UIColor(named: "PrimaryGradientStart")
        sb.barTintColor = .clear
        sb.backgroundColor = .clear
        if let tf = sb.value(forKey: "searchField") as? UITextField {
            tf.textColor = UIColor(named: "OnDarkTextPrimary")
            tf.backgroundColor = UIColor(named: "FillGlass")
        }
        sb.translatesAutoresizingMaskIntoConstraints = false
        return sb
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .medium)
        ai.color = UIColor(named: "PrimaryGradientStart")
        ai.hidesWhenStopped = true
        ai.translatesAutoresizingMaskIntoConstraints = false
        return ai
    }()

    private lazy var emptyLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "No authors found."
        lbl.font = .systemFont(ofSize: 15)
        lbl.textColor = UIColor(named: "OnDarkTextSecondary")
        lbl.textAlignment = .center
        lbl.isHidden = true
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "AppBackground")
        setupHeader()
        setupSearchBar()
        setupCollectionView()
        setupEmptyView()
        setupActivityIndicator()
        fetchNextPage()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    private func setupHeader() {
        view.addSubview(headerLabel)
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            headerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        ])
    }

    private func setupSearchBar() {
        view.addSubview(searchBar)
        searchBar.delegate = self
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 8),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            searchBar.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    private func setupCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.keyboardDismissMode = .onDrag
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(RelatedAuthorCell.self, forCellWithReuseIdentifier: RelatedAuthorCell.identifier)
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
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

    private func setupActivityIndicator() {
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func fetchNextPage() {
        guard !isLoading, hasMore, !isSearching else { return }
        isLoading = true
        if currentPage == 0 { activityIndicator.startAnimating() }

        service.fetchPopularAuthors(page: currentPage) { [weak self] newAuthors in
            guard let self else { return }
            DispatchQueue.main.async {
                self.isLoading = false
                self.activityIndicator.stopAnimating()
                if newAuthors.isEmpty {
                    self.hasMore = false
                } else {
                    self.authors.append(contentsOf: newAuthors)
                    self.currentPage += 1
                    if newAuthors.count < 30 { self.hasMore = false }
                }
                self.emptyLabel.isHidden = !self.authors.isEmpty
                self.collectionView.reloadData()
            }
        }
    }

    private func resetAndFetch() {
        authors = []
        currentPage = 0
        isLoading = false
        hasMore = true
        isSearching = false
        collectionView.reloadData()
        fetchNextPage()
    }

    private func searchAuthors(query: String) {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            resetAndFetch()
            return
        }
        isSearching = true
        activityIndicator.startAnimating()
        service.searchAuthors(query: query) { [weak self] newAuthors in
            guard let self else { return }
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.authors = newAuthors
                self.collectionView.reloadData()
                self.emptyLabel.isHidden = !newAuthors.isEmpty
            }
        }
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
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == authors.count - 6 {
            fetchNextPage()
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = AuthorDetailViewController(author: authors[indexPath.item])
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension AuthorsViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchAuthors(query: searchBar.text ?? "")
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty { resetAndFetch() }
    }
}
