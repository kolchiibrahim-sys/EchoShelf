//
//  AuthManager.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 26.02.26.
//
//
//  AuthManager.swift
//  EchoShelf
//

import Foundation
import FirebaseAuth

final class AuthManager {

    static let shared = AuthManager()
    private let service = AuthService.shared
    private init() {}

    var currentUser: FirebaseAuth.User? {
        Auth.auth().currentUser
    }

    var isLoggedIn: Bool {
        currentUser != nil
    }

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


    func login(
        email: String,
        password: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        service.signIn(email: email, password: password) { result in
            completion(result.map { _ in () })
        }
    }

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

    func resetPassword(
        email: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        service.resetPassword(email: email, completion: completion)
    }


    func signInWithApple(
        presentingVC: UIViewController,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        service.signInWithApple(presentingVC: presentingVC) { result in
            completion(result.map { _ in () })
        }
    }


    func logout() {
        try? service.signOut()
    }
}
