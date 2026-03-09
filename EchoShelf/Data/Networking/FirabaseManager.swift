//
//  FirabaseManager.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 07.03.26.
//
import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

final class FirebaseManager {

    static let shared = FirebaseManager()
    private init() {}

    private let db = Firestore.firestore()

    // MARK: - Setup (AppDelegate-dən çağır)

    static func configure() {
        FirebaseApp.configure()
    }

    // MARK: - Current User

    var currentUser: FirebaseAuth.User? {
        Auth.auth().currentUser
    }

    var userId: String? {
        currentUser?.uid
    }

    // MARK: - User Profile (Firestore)

    /// Yeni qeydiyyatdan sonra Firestore-da user doc yarat
    func createUserProfile(uid: String, name: String, email: String, completion: ((Error?) -> Void)? = nil) {
        let data: [String: Any] = [
            "uid": uid,
            "name": name,
            "email": email,
            "createdAt": FieldValue.serverTimestamp(),
            "subscription": "free"
        ]
        db.collection("users").document(uid).setData(data, merge: true) { error in
            completion?(error)
        }
    }

    /// User profilini oxu
    func fetchUserProfile(completion: @escaping (Result<[String: Any], Error>) -> Void) {
        guard let uid = userId else {
            completion(.failure(FirebaseManagerError.notLoggedIn)); return
        }
        db.collection("users").document(uid).getDocument { snapshot, error in
            if let error {
                completion(.failure(error)); return
            }
            guard let data = snapshot?.data() else {
                completion(.failure(FirebaseManagerError.noData)); return
            }
            completion(.success(data))
        }
    }

    // MARK: - Favorites Sync (Firestore)

    func saveFavoritesToCloud(_ ids: [String], completion: ((Error?) -> Void)? = nil) {
        guard let uid = userId else { return }
        db.collection("users").document(uid).updateData(["favoriteIds": ids]) { error in
            completion?(error)
        }
    }

    func fetchFavoritesFromCloud(completion: @escaping (Result<[String], Error>) -> Void) {
        guard let uid = userId else {
            completion(.failure(FirebaseManagerError.notLoggedIn)); return
        }
        db.collection("users").document(uid).getDocument { snapshot, error in
            if let error { completion(.failure(error)); return }
            let ids = snapshot?.data()?["favoriteIds"] as? [String] ?? []
            completion(.success(ids))
        }
    }

    // MARK: - Auth State

    func addAuthStateListener(_ listener: @escaping (FirebaseAuth.User?) -> Void) -> AuthStateDidChangeListenerHandle {
        Auth.auth().addStateDidChangeListener { _, user in listener(user) }
    }

    func removeAuthStateListener(_ handle: AuthStateDidChangeListenerHandle) {
        Auth.auth().removeStateDidChangeListener(handle)
    }
}

// MARK: - Errors

enum FirebaseManagerError: LocalizedError {
    case notLoggedIn
    case noData

    var errorDescription: String? {
        switch self {
        case .notLoggedIn: return "İstifadəçi daxil olmayıb."
        case .noData:      return "Məlumat tapılmadı."
        }
    }
}
