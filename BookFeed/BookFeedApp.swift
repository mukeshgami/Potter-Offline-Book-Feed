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
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
