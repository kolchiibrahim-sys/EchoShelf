//
//  TabBarCoordinator.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 21.02.26.
//
import UIKit
final class TabBarCoordinator: Coordinator {

    var navigationController: UINavigationController
    private let tabBarController = MainTabBarController()

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    func start() {
        navigationController.setViewControllers([tabBarController], animated: false)
    }
}
