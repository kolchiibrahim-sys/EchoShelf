//
//  SettingsViewModel.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 07.03.26.
//

import Foundation
import FirebaseAuth

final class SettingsViewModel {

    var onSuccess: ((String) -> Void)?
    var onError: ((String) -> Void)?
    var onLoadingChanged: ((Bool) -> Void)?

    // MARK: - User Info

    var email: String {
        Auth.auth().currentUser?.email ?? ""
    }

    var displayName: String {
        Auth.auth().currentUser?.displayName ?? ""
    }

    // MARK: - Update Name

    func updateDisplayName(_ name: String) {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            onError?("The name cannot be empty."); return
        }
        onLoadingChanged?(true)
        let request = Auth.auth().currentUser?.createProfileChangeRequest()
        request?.displayName = name
        request?.commitChanges { [weak self] error in
            self?.onLoadingChanged?(false)
            if let error {
                self?.onError?(error.localizedDescription)
            } else {
                self?.onSuccess?("Name Changed.")
            }
        }
    }

    // MARK: - Change Password

    func changePassword(current: String,
                        new: String,
                        confirm: String) {
        guard !current.isEmpty else { onError?("Enter the current password.");
            return }
        guard new.count >= 6 else { onError?("New password must be at least 6 characters long.");
            return }
        guard new == confirm else { onError?("The passwords do not match.");
            return }

        guard let user = Auth.auth().currentUser, let email = user.email else {
            onError?("User not found."); return
        }

        onLoadingChanged?(true)
        let credential = EmailAuthProvider.credential(withEmail: email,
                                                      password: current)
        user.reauthenticate(with: credential) { [weak self] _, error in
            if let error {
                self?.onLoadingChanged?(false)
                self?.onError?(error.localizedDescription)
                return
            }
            user.updatePassword(to: new) { [weak self] error in
                self?.onLoadingChanged?(false)
                if let error {
                    self?.onError?(error.localizedDescription)
                } else {
                    self?.onSuccess?("Password changed successfully.")
                }
            }
        }
    }

    // MARK: - Send Email Verification

    func sendEmailVerification() {
        onLoadingChanged?(true)
        Auth.auth().currentUser?.sendEmailVerification { [weak self] error in
            self?.onLoadingChanged?(false)
            if let error {
                self?.onError?(error.localizedDescription)
            } else {
                self?.onSuccess?("Verification email sent.")
            }
        }
    }

    // MARK: - Preferences (UserDefaults)

    var isAutoPlayEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "pref_autoplay") }
        set { UserDefaults.standard.set(newValue, forKey: "pref_autoplay") }
    }

    var isAutoDownloadEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "pref_autodownload") }
        set { UserDefaults.standard.set(newValue, forKey: "pref_autodownload") }
    }

    var audioQuality: String {
        get { UserDefaults.standard.string(forKey: "pref_audio_quality") ?? "Yüksək (Lossless)" }
        set { UserDefaults.standard.set(newValue, forKey: "pref_audio_quality") }
    }
}

