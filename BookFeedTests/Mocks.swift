//
//  Mocks.swift
//  BookFeed
//
//  Created by mukesh.gami on 02/11/25.
//

import XCTest
import Combine
@testable import BookFeed

// MockBooksRepo
final class MockBooksRepo: BooksRepoProtocol {
    var cachedBooks: [Book] = []
    var remoteBooks: [Book] = []
    var shouldThrow = false
    
    func loadCachedBooks() async throws -> [Book] {
        if shouldThrow { throw NSError(domain: "FakeBooksRepo", code: 1) }
        return cachedBooks
    }
    
    func syncBooks() async throws -> [Book] {
        if shouldThrow { throw NSError(domain: "FakeBooksRepo", code: 2) }
        cachedBooks = remoteBooks
        return remoteBooks
    }
}


// MockNetworkMonitor
final class MockNetworkMonitor: NetworkMonitorProtocol {
    @Published private(set) var isConnected: Bool
    var isConnectedPublisher: Published<Bool>.Publisher { $isConnected }
    
    init(initial: Bool = false) {
        self.isConnected = initial
    }
    
    func setConnection(_ connected: Bool) {
        isConnected = connected
    }
}
