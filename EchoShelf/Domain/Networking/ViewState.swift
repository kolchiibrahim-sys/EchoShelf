//
//  ViewState.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 12.03.26.
//
import Foundation

enum ViewState<T> {
    case idle
    case loading
    case success(T)
    case failure(APIError)
}
