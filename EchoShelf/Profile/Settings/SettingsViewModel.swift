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
            onError?("Ad boş ola bilməz."); return
        }
        onLoadingChanged?(true)
        let request = Auth.auth().currentUser?.createProfileChangeRequest()
        request?.displayName = name
        request?.commitChanges { [weak self] error in
            self?.onLoadingChanged?(false)
            if let error {
                self?.onError?(error.localizedDescription)
            } else {
                self?.onSuccess?("Ad yeniləndi.")
            }
        }
    }

    // MARK: - Change Password

    func changePassword(current: String, new: String, confirm: String) {
        guard !current.isEmpty else { onError?("Cari şifrə daxil edin."); return }
        guard new.count >= 6 else { onError?("Yeni şifrə minimum 6 simvol olmalıdır."); return }
        guard new == confirm else { onError?("Şifrələr uyğun deyil."); return }

        guard let user = Auth.auth().currentUser, let email = user.email else {
            onError?("İstifadəçi tapılmadı."); return
        }

        onLoadingChanged?(true)
        let credential = EmailAuthProvider.credential(withEmail: email, password: current)
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
                    self?.onSuccess?("Şifrə uğurla dəyişdirildi.")
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
                self?.onSuccess?("Doğrulama emaili göndərildi.")
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
