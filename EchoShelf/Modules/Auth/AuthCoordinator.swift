//
//  AuthCoordinator.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 21.02.26.
//
import UIKit

final class AuthCoordinator: Coordinator {

    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let vc = LoginViewController()

        vc.onLoginSuccess = { [weak self] in
            self?.showMainApp()
        }

        navigationController.setViewControllers([vc], animated: false)
    }

    private func showMainApp() {
        let tabBar = MainTabBarController()
        navigationController.setViewControllers([tabBar], animated: true)
    }
}
