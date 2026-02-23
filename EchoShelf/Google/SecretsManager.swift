//
//  SecretsManager.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 24.02.26.
//
import Foundation

final class SecretsManager {

    static let shared = SecretsManager()
    private init() {}

    private var secrets: NSDictionary? {
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist") else {
            print("Secrets.plist not found")
            return nil
        }

        return NSDictionary(contentsOfFile: path)
    }

    var googleAPIKey: String {
        guard let key = secrets?["API_KEY"] as? String else {
            fatalError("API_KEY not found in Secrets.plist")
        }
        return key
    }
}
