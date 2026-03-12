//
//  AppCoordinator.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 21.02.26.
//
import UIKit
import FirebaseAuth

final class AppCoordinator: Coordinator {

    var navigationController: UINavigationController
    private var authCoordinator: AuthCoordinator?
    private var authListenerHandle: AuthStateDidChangeListenerHandle?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        authListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                if user != nil {
                    self?.showMainApp()
                } else {
                    self?.showAuth()
                }
            }
        }
    }

    private func showAuth() {
        authCoordinator = AuthCoordinator(navigationController: navigationController)
        authCoordinator?.start()
    }

    private func showMainApp() {
        if let handle = authListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
            authListenerHandle = nil
        }
        let tabBarCoordinator = TabBarCoordinator(navigationController: navigationController)
        tabBarCoordinator.start()
    }
}
