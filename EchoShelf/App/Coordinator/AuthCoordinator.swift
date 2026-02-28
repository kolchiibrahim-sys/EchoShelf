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
//        let viewModel = SignInViewModel()
        let vc = SignInViewController(viewModel: .init())

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

    private func showMainApp() {
        let tabBar = MainTabBarController()
        navigationController.setViewControllers([tabBar], animated: true)
    }

    private func showCreateAccount() {
        let viewModel = CreateAccountViewModel()
        let vc = CreateAccountViewController(viewModel: viewModel)

        vc.onCreateSuccess = { [weak self] in
            self?.showMainApp()
        }
        vc.onSignIn = { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }

        navigationController.pushViewController(vc, animated: true)
    }

    private func showForgotPassword() {
        let viewModel = ForgotPasswordViewModel()
        let vc = ForgotPasswordViewController(viewModel: viewModel)

        vc.onBackToSignIn = { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }

        navigationController.pushViewController(vc, animated: true)
    }
}
