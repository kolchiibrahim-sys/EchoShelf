//
//  Home.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 21.02.26.
//
import UIKit

final class HomeViewController: UIViewController {

    private let viewModel = HomeViewModel()

    private let tableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = UIColor(named: "AppBackground")
        tv.separatorStyle = .none
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 100
        return tv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.fetchBooks()   // ⭐️ ƏN VACİB SƏTİR
    }

    private func setupUI() {
        view.backgroundColor = UIColor(named: "AppBackground")

        title = "Home"

        tableView.register(AudiobookCell.self,
                           forCellReuseIdentifier: AudiobookCell.identifier)

        tableView.dataSource = self
        tableView.delegate = self

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func bindViewModel() {
        viewModel.onDataUpdated = { [weak self] in
            self?.tableView.reloadData()
        }
    }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.books.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: AudiobookCell.identifier,
            for: indexPath
        ) as! AudiobookCell

        cell.configure(with: viewModel.books[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let book = viewModel.books[indexPath.row]
        let vc = BookDetailViewController(book: book)
        navigationController?.pushViewController(vc, animated: true)
    }
}
