//
//  AuthService.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 26.02.26.
//
import Foundation

final class AuthService {
    static let shared = AuthService()
    private init() {}

    func signIn(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion(.success(()))
        }
    }

    func signUp(name: String, email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion(.success(()))
        }
    }

    func signInWithApple(completion: @escaping (Result<Void, Error>) -> Void) {
        completion(.success(()))
    }

    func signInWithGoogle(completion: @escaping (Result<Void, Error>) -> Void) {
        completion(.success(()))
    }
}
