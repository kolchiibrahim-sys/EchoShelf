//
//  CreateAccountViewModel.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 26.02.26.
//
import Foundation

final class CreateAccountViewModel {

    var onLoadingChanged: ((Bool) -> Void)?
    var onCreateSuccess: (() -> Void)?
    var onError: ((String) -> Void)?

    private let authManager: AuthManager

    init(authManager: AuthManager = .shared) {
        self.authManager = authManager
    }

    func createAccount(name: String?, email: String?, password: String?) {
        guard let name = name, !name.isEmpty else {
            onError?("Full name is required.")
            return
        }

        guard let email = email, !email.isEmpty else {
            onError?("Email is required.")
            return
        }

        guard isValidEmail(email) else {
            onError?("Please enter a valid email address.")
            return
        }

        guard let password = password, !password.isEmpty else {
            onError?("Password is required.")
            return
        }

        guard password.count >= 6 else {
            onError?("Password must be at least 6 characters.")
            return
        }

        onLoadingChanged?(true)
        authManager.register(name: name, email: email, password: password) { [weak self] result in
            self?.onLoadingChanged?(false)
            switch result {
            case .success:
                self?.onCreateSuccess?()
            case .failure(let error):
                self?.onError?(error.localizedDescription)
            }
        }
    }

    private func isValidEmail(_ email: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
    }
}
