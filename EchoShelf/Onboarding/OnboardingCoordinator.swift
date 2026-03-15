//
//  OnboardingCoordinator.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 14.03.26.
//
import UIKit

final class OnboardingCoordinator: Coordinator {

    var navigationController: UINavigationController
    var onCompleted: (() -> Void)?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let vc = OnboardingViewController()
        vc.onFinish = { [weak self] in
            UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
            self?.onCompleted?()
        }
        vc.onSignIn = { [weak self] in
            UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
            self?.onCompleted?()
        }
        navigationController.setViewControllers([vc], animated: false)
    }
}
