//
//  NetworkServiceProtocol.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 21.02.26.
//
import Foundation

protocol NetworkServiceProtocol {
    func request<T: Decodable>(
        _ endpoint: Endpoint,
        completion: @escaping (Result<T, APIError>) -> Void
    )
}
