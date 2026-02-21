//
//  APIError.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 21.02.26.
//
import Foundation

enum APIError: Error {
    case invalidURL
    case requestFailed
    case decodingFailed
    case unknown
}
