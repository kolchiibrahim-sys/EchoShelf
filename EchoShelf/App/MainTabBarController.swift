//
//  MainTabBarController.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 21.02.26.
//
import UIKit

final class MainTabBarController: UITabBarController {

    private var homeCoordinator: HomeCoordinator?

    private let miniPlayerContainer: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(named: "AppBackground")
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.25
        v.layer.shadowRadius = 10
        v.layer.shadowOffset = CGSize(width: 0, height: -3)
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isHidden = true
        return v
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        setupTabBarAppearance()
        setupMiniPlayerContainer()
        observePlayerEvents()
    }

    private func setupTabs() {
        // Home
        let homeNav = UINavigationController()
        homeNav.tabBarItem = UITabBarItem(
            title: "Home",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )
        homeCoordinator = HomeCoordinator(navigationController: homeNav)
        homeCoordinator?.start()

        // Search
        let search = UINavigationController(rootViewController: SearchViewController())
        search.tabBarItem = UITabBarItem(
            title: "Search",
            image: UIImage(systemName: "magnifyingglass"),
            selectedImage: UIImage(systemName: "magnifyingglass")
        )

        // Favorites
        let favorites = UINavigationController(rootViewController: FavoritesViewController())
        favorites.tabBarItem = UITabBarItem(
            title: "Favorites",
            image: UIImage(systemName: "heart"),
            selectedImage: UIImage(systemName: "heart.fill")
        )

        // Library
        let library = UINavigationController(rootViewController: LibraryViewController())
        library.tabBarItem = UITabBarItem(
            title: "Library",
            image: UIImage(systemName: "books.vertical"),
            selectedImage: UIImage(systemName: "books.vertical.fill")
        )

        // Profile
        let profile = UINavigationController(rootViewController: ProfileViewController())
        profile.tabBarItem = UITabBarItem(
            title: "Profile",
            image: UIImage(systemName: "person"),
            selectedImage: UIImage(systemName: "person.fill")
        )

        viewControllers = [homeNav, search, favorites, library, profile]
    }

    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(named: "AppBackground") ?? UIColor(white: 0.05, alpha: 1)

        let normal: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white.withAlphaComponent(0.4)
        ]
        let selected: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.systemPurple
        ]

        appearance.stackedLayoutAppearance.normal.iconColor    = UIColor.white.withAlphaComponent(0.4)
        appearance.stackedLayoutAppearance.selected.iconColor  = .systemPurple
        appearance.stackedLayoutAppearance.normal.titleTextAttributes   = normal
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = selected

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }

    private func setupMiniPlayerContainer() {
        view.addSubview(miniPlayerContainer)
        NSLayoutConstraint.activate([
            miniPlayerContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            miniPlayerContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            miniPlayerContainer.bottomAnchor.constraint(equalTo: tabBar.topAnchor),
            miniPlayerContainer.heightAnchor.constraint(equalToConstant: 70)
        ])
    }

    private func observePlayerEvents() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(showMiniPlayer),
            name: .playerStarted, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(openFullPlayer),
            name: .openFullPlayer, object: nil
        )
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
