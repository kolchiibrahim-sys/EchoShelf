//
//  MainTabBarController.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 21.02.26.
//
//
//  MainTabBarController.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 21.02.26.
//
import UIKit

final class MainTabBarController: UITabBarController {

    // MARK: - Coordinators
    private var homeCoordinator: HomeCoordinator?

    // MARK: - Mini Player
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

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        setupMiniPlayerContainer()
        observePlayerEvents()
    }

    // MARK: - Tabs
    private func setupTabs() {

        // Home - Coordinator ilə
        let homeNav = UINavigationController()
        homeNav.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house.fill"), tag: 0)
        homeCoordinator = HomeCoordinator(navigationController: homeNav)
        homeCoordinator?.start()

        // Search
        let search = UINavigationController(rootViewController: SearchViewController())
        search.tabBarItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 1)

        // Library
        let library = UINavigationController(rootViewController: LibraryViewController())
        library.tabBarItem = UITabBarItem(title: "Library", image: UIImage(systemName: "books.vertical.fill"), tag: 2)

        // Profile
        let profile = UINavigationController(rootViewController: ProfileViewController())
        profile.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person.fill"), tag: 3)

        viewControllers = [homeNav, search, library, profile]
    }

    // MARK: - Mini Player Layout
    private func setupMiniPlayerContainer() {
        view.addSubview(miniPlayerContainer)

        NSLayoutConstraint.activate([
            miniPlayerContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            miniPlayerContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            miniPlayerContainer.bottomAnchor.constraint(equalTo: tabBar.topAnchor),
            miniPlayerContainer.heightAnchor.constraint(equalToConstant: 70)
        ])
    }

    // MARK: - Notification Listeners
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
