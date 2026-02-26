//
//  LoginViewModel.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 21.02.26.
//
import Foundation

final class SignInViewModel {

    var onLoadingChanged: ((Bool) -> Void)?
    var onLoginSuccess: (() -> Void)?
    var onError: ((String) -> Void)?

    private let authService: AuthService

    init(authService: AuthService = .shared) {
        self.authService = authService
    }

    func login(email: String?, password: String?) {
        guard let email = email, !email.isEmpty,
              let password = password, !password.isEmpty else {
            onError?("Email and password are required.")
            return
        }

        guard isValidEmail(email) else {
            onError?("Please enter a valid email address.")
            return
        }

        guard password.count >= 6 else {
            onError?("Password must be at least 6 characters.")
            return
        }

        onLoadingChanged?(true)
        authService.signIn(email: email, password: password) { [weak self] result in
            self?.onLoadingChanged?(false)
            switch result {
            case .success:
                self?.onLoginSuccess?()
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
