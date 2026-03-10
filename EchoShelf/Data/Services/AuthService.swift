//
//  AuthService.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 26.02.26.
//
import Foundation
import FirebaseAuth
import AuthenticationServices
import CryptoKit
import GoogleSignIn
import FirebaseCore

final class AuthService: NSObject {

    static let shared = AuthService()
    private override init() {}

    // MARK: - Email / Password

    func signIn(email: String, password: String, completion: @escaping (Result<FirebaseAuth.User, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error { completion(.failure(error)); return }
            guard let user = result?.user else {
                completion(.failure(AuthError.unknown)); return
            }
            completion(.success(user))
        }
    }

    func signUp(name: String, email: String, password: String, completion: @escaping (Result<FirebaseAuth.User, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error { completion(.failure(error)); return }
            guard let user = result?.user else {
                completion(.failure(AuthError.unknown)); return
            }
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = name
            changeRequest.commitChanges { _ in
                // Firestore-da user profili yarat
                FirebaseManager.shared.createUserProfile(uid: user.uid, name: name, email: email)
                completion(.success(user))
            }
        }
    }

    func resetPassword(email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error { completion(.failure(error)); return }
            completion(.success(()))
        }
    }

    func signInWithGoogle(
        presentingVC: UIViewController,
        completion: @escaping (Result<FirebaseAuth.User, Error>) -> Void
    ) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            completion(.failure(AuthError.unknown)); return
        }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        GIDSignIn.sharedInstance.signIn(withPresenting: presentingVC) { result, error in
            if let error {
                completion(.failure(error)); return
            }
            guard
                let user = result?.user,
                let idToken = user.idToken?.tokenString
            else {
                completion(.failure(AuthError.unknown)); return
            }
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: user.accessToken.tokenString
            )
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error {
                    completion(.failure(error)); return
                }
                guard let firebaseUser = authResult?.user else {
                    completion(.failure(AuthError.unknown)); return
                }
                // Firestore-da profil yarat (yeni user üçün)
                FirebaseManager.shared.createUserProfile(
                    uid: firebaseUser.uid,
                    name: firebaseUser.displayName ?? "",
                    email: firebaseUser.email ?? ""
                )
                completion(.success(firebaseUser))
            }
        }
    }

    func signOut() throws {
        GIDSignIn.sharedInstance.signOut()
        try Auth.auth().signOut()
    }

    // MARK: - Apple Sign In

    private var currentNonce: String?
    private var appleCompletion: ((Result<FirebaseAuth.User, Error>) -> Void)?

    func signInWithApple(
        presentingVC: ASAuthorizationControllerPresentationContextProviding,
        completion: @escaping (Result<FirebaseAuth.User, Error>) -> Void
    ) {
        let nonce = randomNonceString()
        currentNonce = nonce
        appleCompletion = completion

        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = presentingVC
        controller.performRequests()
    }

    // MARK: - Nonce Helpers

    private func randomNonceString(length: Int = 32) -> String {
        var randomBytes = [UInt8](repeating: 0, count: length)
        _ = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        return randomBytes.map { String(format: "%02hhx", $0) }.joined()
    }

    private func sha256(_ input: String) -> String {
        let data = Data(input.utf8)
        let hash = SHA256.hash(data: data)
        return hash.map { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension AuthService: ASAuthorizationControllerDelegate {
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard
            let appleCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
            let nonce = currentNonce,
            let tokenData = appleCredential.identityToken,
            let tokenString = String(data: tokenData, encoding: .utf8)
        else {
            appleCompletion?(.failure(AuthError.appleCredentialInvalid))
            return
        }

        let credential = OAuthProvider.appleCredential(
            withIDToken: tokenString,
            rawNonce: nonce,
            fullName: appleCredential.fullName
        )

        Auth.auth().signIn(with: credential) { [weak self] result, error in
            if let error {
                self?.appleCompletion?(.failure(error))
            } else if let user = result?.user {
                self?.appleCompletion?(.success(user))
            } else {
                self?.appleCompletion?(.failure(AuthError.unknown))
            }
            self?.appleCompletion = nil
            self?.currentNonce = nil
        }
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        appleCompletion?(.failure(error))
        appleCompletion = nil
        currentNonce = nil
    }
}

// MARK: - Auth Errors

enum AuthError: LocalizedError {
    case unknown
    case appleCredentialInvalid

    var errorDescription: String? {
        switch self {
        case .unknown:              return "Bilinməyən xəta baş verdi."
        case .appleCredentialInvalid: return "Apple giriş məlumatları etibarsızdır."
        }
    }
}
