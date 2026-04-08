//
//  MainTabBarController.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 21.02.26.
//
import UIKit

final class MainTabBarController: UITabBarController {

    var onLogout: (() -> Void)?

    private var homeCoordinator: HomeCoordinator?
    private var libraryCoordinator: LibraryCoordinator?

    private lazy var miniPlayerContainer: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isHidden = true
        return v
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        setupMiniPlayerContainer()
        observePlayerEvents()
    }

    private func setupTabs() {
        let homeNav = UINavigationController()
        homeNav.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house.fill"), tag: 0)
        homeCoordinator = HomeCoordinator(navigationController: homeNav)
        homeCoordinator?.start()

        let search = UINavigationController(rootViewController: SearchViewController())
        search.tabBarItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 1)

        let libraryNav = UINavigationController()
        libraryNav.tabBarItem = UITabBarItem(title: "Library", image: UIImage(systemName: "books.vertical.fill"), tag: 2)
        libraryCoordinator = LibraryCoordinator(navigationController: libraryNav)
        libraryCoordinator?.start()

        let favorites = UINavigationController(rootViewController: FavoritesViewController())
        favorites.tabBarItem = UITabBarItem(title: "Favorites", image: UIImage(systemName: "heart.fill"), tag: 3)

        let authors = UINavigationController(rootViewController: AuthorsViewController())
        authors.tabBarItem = UITabBarItem(title: "Authors", image: UIImage(systemName: "person.2.fill"), tag: 4)

        let profileVM = ProfileViewModel()
        let profileVC = ProfileViewController(viewModel: profileVM)
        profileVC.onLogout = { [weak self] in self?.onLogout?() }
        let profile = UINavigationController(rootViewController: profileVC)
        profile.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person.fill"), tag: 5)

        viewControllers = [homeNav, search, libraryNav, favorites, authors, profile]
    }

    private func setupMiniPlayerContainer() {
        view.addSubview(miniPlayerContainer)
        NSLayoutConstraint.activate([
            miniPlayerContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            miniPlayerContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            miniPlayerContainer.bottomAnchor.constraint(equalTo: tabBar.topAnchor, constant: -8),
            miniPlayerContainer.heightAnchor.constraint(equalToConstant: 70)
        ])
    }

    private func observePlayerEvents() {
        NotificationCenter.default.addObserver(self, selector: #selector(showMiniPlayer), name: .playerStarted, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(openFullPlayer), name: .openFullPlayer, object: nil)
    }

    @objc private func showMiniPlayer() {
        if miniPlayerContainer.subviews.isEmpty {
            let mini = MiniPlayerView()
            mini.translatesAutoresizingMaskIntoConstraints = false
            miniPlayerContainer.addSubview(mini)
            NSLayoutConstraint.activate([
                mini.topAnchor.constraint(equalTo: miniPlayerContainer.topAnchor),
                mini.bottomAnchor.constraint(equalTo: miniPlayerContainer.bottomAnchor),
                mini.leadingAnchor.constraint(equalTo: miniPlayerContainer.leadingAnchor),
                mini.trailingAnchor.constraint(equalTo: miniPlayerContainer.trailingAnchor)
            ])
        }
        miniPlayerContainer.isHidden = false
    }

    @objc private func openFullPlayer() {
        let playerVC = PlayerViewController()
        playerVC.modalPresentationStyle = .fullScreen
        present(playerVC, animated: true)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
