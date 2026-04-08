//
//  GeminiService.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 29.03.26.
//
import Foundation

final class GeminiService {

    private let apiKey = "AIzaSyCUUBY9D_RjmpGc4klRtthD2ywG3Jm1K28"

    func ask(prompt: String, completion: @escaping (String?) -> Void) {
        let urlString = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=\(apiKey)"
        guard let url = URL(string: urlString) else { completion(nil); return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "contents": [["parts": [["text": prompt]]]]
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data else { completion(nil); return }
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
            let text = (json?["candidates"] as? [[String: Any]])?.first
                .flatMap { $0["content"] as? [String: Any] }
                .flatMap { $0["parts"] as? [[String: Any]] }?.first
                .flatMap { $0["text"] as? String }
            completion(text)
        }.resume()
    }

    func ask(prompt: String) async -> String? {
        await withCheckedContinuation { continuation in
            ask(prompt: prompt) { result in
                continuation.resume(returning: result)
            }
        }
    }
}
