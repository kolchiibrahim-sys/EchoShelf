//
//  AppCoordinator.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 21.02.26.
import UIKit

final class AppCoordinator: Coordinator {
    var navigationController: UINavigationController
    private var authCoordinator: AuthCoordinator?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        if AuthManager.shared.isLoggedIn {
            showMainApp()
        } else {
            showAuth()
        }
    }

    private func showAuth() {
        authCoordinator = AuthCoordinator(navigationController: navigationController)
        authCoordinator?.start()
    }

    private func showMainApp() {
        let tabBarCoordinator = TabBarCoordinator(navigationController: navigationController)
        tabBarCoordinator.start()
    }
}
