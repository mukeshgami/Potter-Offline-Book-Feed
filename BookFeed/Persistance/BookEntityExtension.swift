//
//  BookEntiryExtension.swift
//  BookFeed
//
//  Created by mukesh.gami on 01/11/25.
//

import Foundation
import CoreData

extension BookEntity {
    func toDomainModel() -> Book {
        Book(
            id: id ?? UUID(),
            number: Int(number),
            title: title ?? "Unknown",
            releaseDate: releaseDate ?? "Unknown",
            cover: cover ?? "",
            index: Int(index)
        )
    }
    
    func update(from book: Book) {
        id = book.id
        number = Int32(book.number)
        title = book.title
        releaseDate = book.releaseDate
        cover = book.cover
        index = Int32(book.index)
    }
}
