//
//  FlexibleInt.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 21.02.26.
//
import Foundation

struct FlexibleInt: Codable {
    let value: Int

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let intValue = try? container.decode(Int.self) {
            value = intValue
            return
        }

        if let stringValue = try? container.decode(String.self),
           let intValue = Int(stringValue) {
            value = intValue
            return
        }

        value = 0
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}
