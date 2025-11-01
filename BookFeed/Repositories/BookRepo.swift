//
//  BookRepo.swift
//  BookFeed
//
//  Created by mukesh.gami on 01/11/25.
//

import Foundation
import CoreData

protocol BooksRepoProtocol {
    func loadCachedBooks() async throws -> [Book]
    func syncBooks() async throws -> [Book]
}

final class BooksRepository: BooksRepoProtocol {
    private let remote: RemoteDataSourceProtocol
    private let local: PersistenceController

    init(remote: RemoteDataSourceProtocol = RemoteDataSource(),
         local: PersistenceController = .shared) {
        self.remote = remote
        self.local = local
    }

    func loadCachedBooks() async throws -> [Book] {
        let ctx = local.viewContext
        let req: NSFetchRequest<BookEntity> = BookEntity.fetchRequest()
        req.sortDescriptors = [NSSortDescriptor(key: "releaseDate", ascending: true)]
        let results = try ctx.fetch(req)
        return results.map { $0.toDomainModel() }
    }

    func syncBooks() async throws -> [Book] {
        
        let fetched = try await remote.fetchBooks()
        let bg = local.newBackgroundContext()
        
        bg.performAndWait {
            for book in fetched {
                let fetch: NSFetchRequest<BookEntity> = BookEntity.fetchRequest()
                fetch.predicate = NSPredicate(format: "number == %d", book.number as CVarArg)
                fetch.fetchLimit = 1
                let existing = (try? bg.fetch(fetch))?.first
                let entity = existing ?? BookEntity(context: bg)
                entity.update(from: book)
            }
            do {
                try bg.save()
            } catch {
                print("CoreData save error: \(error)")
            }
        }
        return fetched
    }
}
