//
//  HomeCoordinator.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 21.02.26.
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

    func showAllBooks(type: AllBooksType) {
        let viewModel = AllBooksViewModel(type: type)
        let vc = AllBooksViewController(viewModel: viewModel)
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }

    func showGenreSearch(genre: String) {
        let viewModel = GenreViewModel(genre: genre)
        let vc = GenreViewController(viewModel: viewModel)
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }

    func showBookDetail(book: Audiobook) {
        let vc = BookDetailViewController(book: book)
        navigationController.pushViewController(vc, animated: true)
    }

    func showEbookDetail(ebook: Ebook) {
        let vc = BookDetailViewController(ebook: ebook)
        navigationController.pushViewController(vc, animated: true)
    }
}
