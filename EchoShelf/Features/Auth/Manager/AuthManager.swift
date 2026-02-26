//
//  AuthManager.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 26.02.26.
//
import Foundation

final class AuthManager {

    static let shared = AuthManager()
    private let service = AuthService.shared

    private init() {}

    func login(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        service.signIn(email: email, password: password) { result in
            if case .success = result {
                
            }
            completion(result)
        }
    }

    func register(name: String, email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        service.signUp(name: name, email: email, password: password) { result in
            if case .success = result {
                // TODO: Firebase gələndə yeni user session buraya
            }
            completion(result)
        }
    }

    func resetPassword(email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        service.resetPassword(email: email, completion: completion)
    }

    func signInWithApple(completion: @escaping (Result<Void, Error>) -> Void) {
        service.signInWithApple(completion: completion)
    }

    func signInWithGoogle(completion: @escaping (Result<Void, Error>) -> Void) {
        service.signInWithGoogle(completion: completion)
    }

    func logout() {
    }
}
