//
//  AuthManager.swift
//  EchoShelf
//

import UIKit
import FirebaseAuth

final class AuthManager {

    static let shared = AuthManager()
    private let service = AuthService.shared
    private init() {}

    // MARK: - Current User

    var currentUser: FirebaseAuth.User? {
        Auth.auth().currentUser
    }

    var isLoggedIn: Bool {
        currentUser != nil
    }

    // MARK: - Auth State Listener

    private var authStateHandle: AuthStateDidChangeListenerHandle?

    func startListening(onChange: @escaping (FirebaseAuth.User?) -> Void) {
        authStateHandle = Auth.auth().addStateDidChangeListener { _, user in
            onChange(user)
        }
    }

    func stopListening() {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    // MARK: - Login

    func login(
        email: String,
        password: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        service.signIn(email: email, password: password) { result in
            completion(result.map { _ in () })
        }
    }

    // MARK: - Register

    func register(
        name: String,
        email: String,
        password: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        service.signUp(name: name, email: email, password: password) { result in
            completion(result.map { _ in () })
        }
    }

    // MARK: - Reset Password

    func resetPassword(
        email: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        service.resetPassword(email: email, completion: completion)
    }

    // MARK: - Apple Sign In

    func signInWithApple(
        presentingVC: UIViewController,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        service.signInWithApple(presentingVC: presentingVC) { result in
            completion(result.map { _ in () })
        }
    }

    // MARK: - Google Sign In (SDK əlavə olunanda aktiv et)

    func signInWithGoogle(completion: @escaping (Result<Void, Error>) -> Void) {
        completion(.failure(AuthError.unknown))
    }

    // MARK: - Logout

    func logout() {
        try? service.signOut()
    }
}
