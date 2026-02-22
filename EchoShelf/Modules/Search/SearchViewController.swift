//
//  Search.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 21.02.26.
import UIKit
import Kingfisher

final class SearchViewController: UIViewController {

    private let viewModel = SearchViewModel()

    private let searchBar = UISearchBar()
    private let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Search"
        view.backgroundColor = .systemBackground

        setupUI()
        bindViewModel()
    }

    private func setupUI() {

        searchBar.placeholder = "Search audiobooks"
        searchBar.delegate = self
        searchBar.returnKeyType = .search
        searchBar.enablesReturnKeyAutomatically = false

        tableView.register(AudiobookCell.self,
                           forCellReuseIdentifier: AudiobookCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.keyboardDismissMode = .onDrag

        view.addSubview(searchBar)
        view.addSubview(tableView)

        searchBar.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func bindViewModel() {
        viewModel.onDataUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
}

extension SearchViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        viewModel.books.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: AudiobookCell.identifier,
            for: indexPath
        ) as! AudiobookCell

        let book = viewModel.books[indexPath.row]
        cell.configure(with: book)

        return cell
    }
}

extension SearchViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {

        let book = viewModel.books[indexPath.row]
        let vc = BookDetailViewController(book: book)
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension SearchViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("SEARCH BUTTON CLICKED:", searchBar.text ?? "")
        viewModel.search(query: searchBar.text ?? "")
        searchBar.resignFirstResponder()
    }
}
