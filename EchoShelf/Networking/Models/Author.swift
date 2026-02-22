//
//  Author.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 22.02.26.
//
import Foundation

struct Author: Decodable {
    let id: String?
    let firstName: String?
    let lastName: String?

    var name: String {
        "\(firstName ?? "") \(lastName ?? "")"
    }

    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
    }
}
