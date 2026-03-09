//
//  ProfileViewModel.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 27.02.26.
//
import Foundation
import FirebaseAuth

final class ProfileViewModel {

    var onLogout: (() -> Void)?

    // MARK: - User Info

    var displayName: String {
        Auth.auth().currentUser?.displayName ?? "İstifadəçi"
    }

    var email: String {
        Auth.auth().currentUser?.email ?? ""
    }

    var initials: String {
        let parts = displayName.split(separator: " ")
        let letters = parts.prefix(2).compactMap { $0.first }
        return letters.isEmpty ? "?" : String(letters).uppercased()
    }

    // MARK: - Logout

    func logout() {
        AuthManager.shared.logout()
        onLogout?()
    }
}
