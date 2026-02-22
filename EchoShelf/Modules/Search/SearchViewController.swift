//
//  Search.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 21.02.26.
import UIKit

final class SearchViewController: UIViewController {

    private let viewModel = SearchViewModel()

    // MARK: Background
    private let backgroundView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(named: "AppBackground")
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Search"
        lbl.textColor = .white
        lbl.font = .systemFont(ofSize: 32, weight: .bold)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let searchField: UITextField = {
        let tf = UITextField()
        tf.backgroundColor = UIColor(white: 1, alpha: 0.08)
        tf.textColor = .white
        tf.layer.cornerRadius = 18
        tf.returnKeyType = .search
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.heightAnchor.constraint(equalToConstant: 56).isActive = true
        
        let icon = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        icon.tintColor = UIColor(white: 1, alpha: 0.6)
        icon.frame = CGRect(x: 0, y: 0, width: 20, height: 20)

        let container = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 56))
        icon.center = container.center
        container.addSubview(icon)

        tf.leftView = container
        tf.leftViewMode = .always

        tf.attributedPlaceholder = NSAttributedString(
            string: "Books, authors, narrators",
            attributes: [.foregroundColor: UIColor(white: 1, alpha: 0.5)]
        )

        return tf
    }()

    private let tableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 120, right: 0)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }

    private func setupUI() {

        tableView.register(AudiobookCell.self, forCellReuseIdentifier: AudiobookCell.identifier)
        tableView.register(RecentSearchCell.self, forCellReuseIdentifier: RecentSearchCell.identifier)

        tableView.dataSource = self
        tableView.delegate = self

        view.addSubview(backgroundView)
        view.addSubview(titleLabel)
        view.addSubview(searchField)
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            searchField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 18),
            searchField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            searchField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            tableView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        searchField.addTarget(self, action: #selector(searchPressed), for: .editingDidEndOnExit)
    }

    private func bindViewModel() {
        viewModel.onDataUpdated = { [weak self] in
            self?.tableView.reloadData()
        }
    }

    @objc private func searchPressed() {
        viewModel.search(query: searchField.text ?? "")
        view.endEditing(true)
    }

    @objc private func clearAllTapped() {
        viewModel.clearAllRecents()
    }
}
extension SearchViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2 // Recent + Results
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? viewModel.recentSearches.count : viewModel.books.count
    }

    // MARK: Header view (Recent + Clear All)
    func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView? {

        if section == 0 && viewModel.recentSearches.isEmpty { return nil }
        if section == 1 && viewModel.books.isEmpty { return nil }

        let container = UIView()

        let label = UILabel()
        label.textColor = UIColor(white: 1, alpha: 0.7)
        label.font = .systemFont(ofSize: 14, weight: .semibold)

        if section == 0 {
            label.text = "Recent Searches"
        } else {
            label.text = "Results"
        }

        container.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        // Clear All button yalnız Recent üçün
        if section == 0 {
            let clearButton = UIButton(type: .system)
            clearButton.setTitle("Clear All", for: .normal)
            clearButton.addTarget(self, action: #selector(clearAllTapped), for: .touchUpInside)
            container.addSubview(clearButton)
            clearButton.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                clearButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
                clearButton.centerYAnchor.constraint(equalTo: label.centerYAnchor)
            ])
        }

        return container
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 && viewModel.recentSearches.isEmpty { return 0 }
        if section == 1 && viewModel.books.isEmpty { return 0 }
        return 40
    }

    // MARK: Cells
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // RECENT SEARCH CELL
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: RecentSearchCell.identifier,
                for: indexPath
            ) as! RecentSearchCell

            let query = viewModel.recentSearches[indexPath.row]
            cell.configure(with: query)

            cell.onDeleteTapped = { [weak self] in
                self?.viewModel.deleteRecent(at: indexPath.row)
            }

            return cell
        }

        // RESULT CELL
        let cell = tableView.dequeueReusableCell(
            withIdentifier: AudiobookCell.identifier,
            for: indexPath
        ) as! AudiobookCell

        cell.backgroundColor = .clear
        cell.configure(with: viewModel.books[indexPath.row])
        return cell
    }

    // Tap recent → search again
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if indexPath.section == 0 {
            let text = viewModel.recentSearches[indexPath.row]
            searchField.text = text
            viewModel.search(query: text)
            return
        }

        let book = viewModel.books[indexPath.row]
        let vc = BookDetailViewController(book: book)
        navigationController?.pushViewController(vc, animated: true)
    }
}
