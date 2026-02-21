//
//  FlexibleInt.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 21.02.26.
//
import Foundation

struct FlexibleInt: Decodable {
    let value: Int

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let int = try? container.decode(Int.self) {
            value = int
        } else if let string = try? container.decode(String.self),
                  let int = Int(string) {
            value = int
        } else {
            throw DecodingError.typeMismatch(
                Int.self,
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Cannot decode Int"
                )
            )
        }
    }
}
