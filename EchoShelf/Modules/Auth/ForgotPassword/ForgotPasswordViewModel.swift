//
//  ForgotPasswordViewModel.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 26.02.26.
//
import Foundation

final class ForgotPasswordViewModel {

    var onLoadingChanged: ((Bool) -> Void)?
    var onResetSuccess: (() -> Void)?
    var onError: ((String) -> Void)?

    private let authService: AuthService

    init(authService: AuthService = .shared) {
        self.authService = authService
    }

    func resetPassword(email: String?) {
        guard let email = email, !email.isEmpty else {
            onError?("Email is required.")
            return
        }

        guard isValidEmail(email) else {
            onError?("Please enter a valid email address.")
            return
        }

        onLoadingChanged?(true)
        authService.resetPassword(email: email) { [weak self] result in
            self?.onLoadingChanged?(false)
            switch result {
            case .success:
                self?.onResetSuccess?()
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
