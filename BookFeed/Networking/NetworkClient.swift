//
//  NetworkClient.swift
//  BookFeed
//
//  Created by mukesh.gami on 01/11/25.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case httpError(Int)
    case decodingError(Error)
    case other(Error)
}

final class NetworkClient {
    
    static let shared = NetworkClient()
    private init() {}

    func get<T: Decodable>(_ url: URL) async throws -> T {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let (data, response) = try await URLSession.shared.data(for: request)
        //print("Data:", String(data: data, encoding: .utf8))
        if let http = response as? HTTPURLResponse {
            guard (200...299).contains(http.statusCode) else {
                throw NetworkError.httpError(http.statusCode)
            }
        }

        do {
            let decoded = try JSONDecoder().decode(T.self, from: data)
            return decoded
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
}
