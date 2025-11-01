//
//  BooksViewModel.swift
//  BookFeed
//
//  Created by mukesh.gami on 01/11/25.
//

import Foundation
import Combine

@MainActor
final class BooksViewModel: ObservableObject {
    
    @Published private(set) var books: [Book] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var isOnline: Bool = false {
        didSet {
            if isOnline {
                Task {
                    await syncWithRemote()
                }
            }
        }
    }
    
    private let repository: BooksRepoProtocol
    private var cancellables = Set<AnyCancellable>()

    init(repository: BooksRepoProtocol, monitor: NetworkMonitor) {
        
        self.repository = repository
        self.isOnline = monitor.isConnected
        
        monitor.$isConnected
            .receive(on: DispatchQueue.main)
            .assign(to: \.isOnline, on: self)
            .store(in: &cancellables)
    }

    func loadInitial() {
        Task {
            await loadCached()
            await syncWithRemote()
        }
    }

    func loadCached() async {
        do {
            let cached = try await repository.loadCachedBooks()
            print("cached: ", cached)
            self.books = cached
            self.errorMessage = nil
        } catch {
            self.errorMessage = "Failed to load saved books."
        }
    }

    func syncWithRemote() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let remote = try await repository.syncBooks()
            print("remote: ", remote)
            self.books = remote
            self.errorMessage = nil
        } catch {
            print("Error: ", error)
            self.errorMessage = "Unable to sync due network problem."
        }
    }

    func refreshTriggered() {
        Task {
            await syncWithRemote()
        }
    }
    
    func search(_ query: String) {
        Task { @MainActor in
            if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                await loadCached()
            } else {
                let lower = query.lowercased()
                let filtered = books.filter {
                    $0.title.lowercased().contains(lower)
                }
                self.books = filtered
            }
        }
    }
}
