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
    @Published var isOnline: Bool {
        didSet {
            if isOnline {
                Task {
                    await startSyncIfNeeded()
                }
            }
        }
    }
    
    private let repository: BooksRepoProtocol
    private var cancellables = Set<AnyCancellable>()
    
    private var remoteSyncStatus: SyncStatus {
        didSet {
             print("remoteSyncStatus-didset: ", remoteSyncStatus)
        }
    }

    init(repository: BooksRepoProtocol, monitor: NetworkMonitor) {
        self.repository = repository
        self.isOnline = monitor.isConnected
        self.remoteSyncStatus = .inactive
        
        monitor.$isConnected
            .receive(on: DispatchQueue.main)
            .assign(to: \.isOnline, on: self)
            .store(in: &cancellables)
    }

    func loadInitial() {
        Task {
            await loadCached()
            await startSyncIfNeeded()
        }
    }

    func loadCached() async {
        do {
            let cached = try await repository.loadCachedBooks()
            print("Load cached")
            self.books = cached
            self.errorMessage = nil
        } catch {
            self.errorMessage = "Failed to load saved books."
        }
    }

    func syncWithRemote() async {
        
        guard remoteSyncStatus == .inactive else {
            print("remote sync already running or recently completed")
            return
        }
        
        guard isOnline else {
            print("no sync since internet not available")
            return
        }
        
        isLoading = true
        remoteSyncStatus = .started
        defer {
            isLoading = false
        }

        do {
            let _ = try await repository.syncBooks()
            print("Load remote")
            remoteSyncStatus = .completed
            await loadCached()
            remoteSyncStatus = .inactive
            errorMessage = nil
        } catch {
            print("remote sync failed. Error: \(error)")
            remoteSyncStatus = .inactive
            errorMessage = "Unable to sync due to network problem."
        }
    }

    private func startSyncIfNeeded() async {
        guard isOnline else { return }
        guard remoteSyncStatus == .inactive else { return }
        await syncWithRemote()
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

enum SyncStatus: String {
    case started
    case inprogress
    case completed
    case inactive
}
