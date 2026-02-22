//
//  AudiobooksResponse.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 21.02.26.
//
import Foundation

struct AudiobooksResponse: Decodable {
    let books: [Audiobook]
}
