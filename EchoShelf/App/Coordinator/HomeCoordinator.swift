//
//  HomeCoordinator.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 28.02.26.
//
import UIKit

final class HomeCoordinator: Coordinator {

    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let vc = HomeViewController()
        vc.coordinator = self
        navigationController.setViewControllers([vc], animated: false)
    }

    // MARK: - View All
    func showAllBooks(type: AllBooksType) {
        let viewModel = AllBooksViewModel(type: type)
        let vc = AllBooksViewController(viewModel: viewModel)
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }

    func showGenreSearch(genre: String) {
        let vc = SearchViewController()
        vc.preselectedGenre = genre
        navigationController.pushViewController(vc, animated: true)
    }

    // MARK: - Book Detail
    func showBookDetail(book: Audiobook) {
        let vc = BookDetailViewController(book: book)
        navigationController.pushViewController(vc, animated: true)
    }
}
