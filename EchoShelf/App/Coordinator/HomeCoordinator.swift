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
        let viewModel = GenreViewModel(genre: genre)
        let vc = GenreViewController(viewModel: viewModel)
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }

    func showBookDetail(book: Audiobook) {
        let vc = BookDetailViewController(book: book, favoritesViewModel: favoritesViewModel)
        navigationController.pushViewController(vc, animated: true)
    }

    func showEbookDetail(ebook: Ebook) {
        let vc = BookDetailViewController(ebook: ebook, favoritesViewModel: favoritesViewModel)
        navigationController.pushViewController(vc, animated: true)
    }
}
