//
//  AppCoordinator.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 21.02.26.
//
import UIKit

final class AppCoordinator: Coordinator {

    var navigationController: UINavigationController
    private var tabBarCoordinator: TabBarCoordinator?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        showMainFlow()
    }

    private func showMainFlow() {
        let tabBarCoordinator = TabBarCoordinator(navigationController: navigationController)
        self.tabBarCoordinator = tabBarCoordinator
        tabBarCoordinator.start()
    }
}
