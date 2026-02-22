//
//  Search.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 21.02.26.
import UIKit

final class SearchViewController: UIViewController {

    private let viewModel = SearchViewModel()

    private let backgroundImage: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "LoginBG"))
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
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
        tf.placeholder = "Search audiobooks..."
        tf.backgroundColor = UIColor(white: 1, alpha: 0.08)
        tf.textColor = .white
        tf.layer.cornerRadius = 18
        tf.returnKeyType = .search
        tf.translatesAutoresizingMaskIntoConstraints = false
        
        let icon = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        icon.tintColor = UIColor(white: 1, alpha: 0.6)
        icon.frame = CGRect(x: 0, y: 0, width: 20, height: 20)

        let container = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 56))
        icon.center = container.center
        container.addSubview(icon)

        tf.leftView = container
        tf.leftViewMode = .always
        tf.heightAnchor.constraint(equalToConstant: 56).isActive = true

        tf.attributedPlaceholder = NSAttributedString(
            string: "Search audiobooks...",
            attributes: [.foregroundColor: UIColor(white: 1, alpha: 0.5)]
        )

        return tf
    }()

    private let tableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 100, right: 0)
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
        tableView.dataSource = self
        tableView.delegate = self

        view.addSubview(backgroundImage)
        view.addSubview(titleLabel)
        view.addSubview(searchField)
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),

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
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }

    @objc private func searchPressed() {
        viewModel.search(query: searchField.text ?? "")
        view.endEditing(true)
    }
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.books.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: AudiobookCell.identifier,
            for: indexPath
        ) as! AudiobookCell

        cell.backgroundColor = .clear
        cell.configure(with: viewModel.books[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let book = viewModel.books[indexPath.row]
        let vc = BookDetailViewController(book: book)
        navigationController?.pushViewController(vc, animated: true)
    }
}
