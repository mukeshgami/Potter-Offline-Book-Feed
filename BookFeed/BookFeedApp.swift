//
//  BookFeedApp.swift
//  BookFeed
//
//  Created by mukesh.gami on 01/11/25.
//

import SwiftUI
import CoreData

@main
struct BookFeedApp: App {
    var body: some Scene {
        
        let bookRepo = BooksRepository()
        let bookViewModel = BooksViewModel(repository: bookRepo, monitor: NetworkMonitor.shared)
        
        WindowGroup {
            HomeView(vm: bookViewModel)
        }
    }
}
