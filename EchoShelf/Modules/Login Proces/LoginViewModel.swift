//
//  LoginViewModel.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 21.02.26.
//
import Foundation

final class LoginViewModel {

    var onLoadingChanged: ((Bool) -> Void)?
    var onLoginSuccess: (() -> Void)?
    var onError: ((String) -> Void)?

    func login(email: String?, password: String?) {

        guard let email = email, !email.isEmpty,
              let password = password, !password.isEmpty else {
            onError?("Email and password required")
            return
        }

        onLoadingChanged?(true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.onLoadingChanged?(false)
            self?.onLoginSuccess?()
        }
    }
}
