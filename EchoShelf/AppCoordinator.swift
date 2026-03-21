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
    private var authListenerHandle: AuthStateDidChangeListenerHandle?
    private var onboardingCoordinator: OnboardingCoordinator?
    private var authCoordinator: AuthCoordinator?
    private var hasRouted = false

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        UserDefaults.standard.removeObject(forKey: "hasSeenOnboarding")
        authListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self, !self.hasRouted else { return }
            self.hasRouted = true
            DispatchQueue.main.async {
                if user != nil {
                    self.showMainApp()
                } else if !UserDefaults.standard.bool(forKey: "hasSeenOnboarding") {
                    self.showOnboarding()
                } else {
                    self.showAuth()
                }
            }
        }
    }

    private func showOnboarding() {
        let coordinator = OnboardingCoordinator(navigationController: navigationController)
        coordinator.onCompleted = { [weak self] in
            self?.onboardingCoordinator = nil
            self?.showAuth()
        }
        onboardingCoordinator = coordinator
        coordinator.start()
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
        onboardingCoordinator = nil
        authCoordinator = nil
        let coordinator = TabBarCoordinator(navigationController: navigationController)
        coordinator.start()
    }
}
