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
        showAuthFlow()
    }

    private func showAuthFlow() {
        let authCoordinator = AuthCoordinator(navigationController: navigationController)
        self.authCoordinator = authCoordinator
        authCoordinator.start()
    }
}
