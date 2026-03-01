import UIKit

final class HomeCoordinator: Coordinator {

    var navigationController: UINavigationController
    private let favoritesViewModel: FavoritesViewModel

    init(navigationController: UINavigationController,
         favoritesViewModel: FavoritesViewModel) {
        self.navigationController = navigationController
        self.favoritesViewModel = favoritesViewModel
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
        let vc = SearchViewController()
        vc.preselectedGenre = genre
        vc.favoritesViewModel = favoritesViewModel
        navigationController.pushViewController(vc, animated: true)
    }

    func showBookDetail(book: Audiobook) {
        let vc = BookDetailViewController(book: book, favoritesViewModel: favoritesViewModel)
        navigationController.pushViewController(vc, animated: true)
    }
}
