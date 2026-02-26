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
        let vc = SignInViewController()

        vc.onLoginSuccess = { [weak self] in
            self?.showMainApp()
        }

        vc.onCreateAccount = { [weak self] in
            self?.showCreateAccount()
        }

        vc.onForgotPassword = { [weak self] in
            self?.showForgotPassword()
        }

        navigationController.setViewControllers([vc], animated: false)
    }

    // MARK: - Navigation

    private func showMainApp() {
        let tabBar = MainTabBarController()
        navigationController.setViewControllers([tabBar], animated: true)
    }

    private func showCreateAccount() {
        // TODO: Replace with your RegisterViewController
        let vc = UIViewController()
        vc.view.backgroundColor = UIColor(red: 0.09, green: 0.10, blue: 0.16, alpha: 1.0)
        vc.title = "Create Account"
        navigationController.pushViewController(vc, animated: true)
    }

    private func showForgotPassword() {
        // TODO: Replace with your ForgotPasswordViewController
        let vc = UIViewController()
        vc.view.backgroundColor = UIColor(red: 0.09, green: 0.10, blue: 0.16, alpha: 1.0)
        vc.title = "Forgot Password"
        navigationController.pushViewController(vc, animated: true)
    }
}
