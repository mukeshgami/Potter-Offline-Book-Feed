//
//  Book.swift
//  BookFeed
//
//  Created by mukesh.gami on 01/11/25.
//

import Foundation

// MARK: - Book
struct Book: Identifiable, Codable {
    var id = UUID()
    let number: Int
    let title, releaseDate : String
    let cover: String
    let index: Int
    
    enum CodingKeys: String, CodingKey {
        case number
        case title
        case releaseDate
        case cover
        case index
    }
}
