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
        let vc = AllBooksViewController(viewModel: AllBooksViewModel(type: type))
        vc.coordinator = self
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }

    func showGenreSearch(genre: String) {
        let vc = GenreViewController(viewModel: GenreViewModel(genre: genre))
        vc.coordinator = self
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }

    func showBookDetail(book: Audiobook) {
        let vc = BookDetailViewController(book: book)
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }

    func showEbookDetail(ebook: Ebook) {
        let vc = BookDetailViewController(ebook: ebook)
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }

    func showAuthorDetail(author: Author) {
        let vc = AuthorDetailViewController(author: author)
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }
}
