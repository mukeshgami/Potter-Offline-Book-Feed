//
//  BookFeedTests.swift
//  BookFeedTests
//
//  Created by mukesh.gami on 01/11/25.
//

import XCTest
@testable import BookFeed

//UnitTests
@MainActor
final class BooksViewModelTests: XCTestCase {
    
    var fakeRepo: MockBooksRepo!
    var monitor: MockNetworkMonitor!
    var sut: BooksViewModel!
    
    override func setUp() async throws {
        fakeRepo = MockBooksRepo()
        monitor = MockNetworkMonitor()
        sut = BooksViewModel(repository: fakeRepo, monitor: monitor)
    }
    
    override func tearDown() async throws {
        sut = nil
        monitor = nil
        fakeRepo = nil
    }
    
    // TestCase#1 - loadCached success -> books updated
    func test_loadCached_success_updatesBooks() async throws {
        
        fakeRepo.cachedBooks = [
            Book(number: 1, title: "Harry Potter", releaseDate: "Jun 26, 1997", cover: "", index: 1),
            Book(number: 2, title: "Harry Potter New chapter", releaseDate: "Jun 26, 1999", cover: "", index: 2)
        ]
        
        await sut.loadCached()
        
        XCTAssertEqual(sut.books.count, 2)
        XCTAssertEqual(sut.books[0].title, "Harry Potter")
        XCTAssertNil(sut.errorMessage)
    }
    
    // TestCase#2 - syncWithRemote success -> repo persists remote -> viewmodel reloads cache -> books updated
    func test_syncWithRemote_success_persistsAndReloadsFromCache() async throws {
        fakeRepo.cachedBooks = [] // start empty
        fakeRepo.remoteBooks = [
            Book(number: 1, title: "Harry Potter", releaseDate: "Jun 26, 1997", cover: "", index: 1)
        ]
        sut.isOnline = true
        
        await sut.syncWithRemote()
        
        XCTAssertEqual(sut.books.count, 1)
        XCTAssertEqual(sut.books.first?.title, "Harry Potter")
        XCTAssertNil(sut.errorMessage)
        XCTAssertFalse(sut.isLoading)
    }
    
    // TestCase#3 - syncWithRemote failure -> errorMessage and isLoading false
    func test_syncWithRemote_failure_setsErrorMessage_and_stopsLoading() async throws {
        // Arrange
        fakeRepo.shouldThrow = true
        sut.isOnline = true
        
        await sut.syncWithRemote()
        
        XCTAssertFalse(sut.isLoading)
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertEqual(sut.errorMessage, "Unable to sync due to network problem.")
    }
}
