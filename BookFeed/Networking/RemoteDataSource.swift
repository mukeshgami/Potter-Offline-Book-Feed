//
//  RemoteDataSource.swift
//  BookFeed
//
//  Created by mukesh.gami on 01/11/25.
//

import Foundation

protocol RemoteDataSourceProtocol {
    func fetchBooks() async throws -> [Book]
}

final class RemoteDataSource: RemoteDataSourceProtocol {
    private let baseURL = URL(string: "https://potterapi-fedeperin.vercel.app/en/books")!

    func fetchBooks() async throws -> [Book] {
        return try await NetworkClient.shared.get(baseURL)
    }
}
