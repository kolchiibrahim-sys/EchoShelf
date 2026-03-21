//
//  AudiobookProtocol.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 21.02.26.
//
import Foundation

protocol AudiobookServiceProtocol {
    func fetchAudiobooks(
        page: Int,
        completion: @escaping (Result<[Audiobook], APIError>) -> Void
    )

    func searchAudiobooks(
        query: String,
        completion: @escaping (Result<[Audiobook], APIError>) -> Void
    )

    func fetchAudiobookDetail(
        id: Int,
        completion: @escaping (Result<Audiobook, APIError>) -> Void
    )

    func fetchByGenre(
        subject: String,
        page: Int,
        completion: @escaping (Result<[Audiobook], APIError>) -> Void
    )
}
