//
//  NetworkMonitor.swift
//  BookFeed
//
//  Created by mukesh.gami on 01/11/25.
//

import Foundation
import Network
import Combine

@MainActor
final class NetworkMonitor: ObservableObject {
    
    static let shared = NetworkMonitor()
    @Published private(set) var isConnected: Bool = true

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitorQueue")

    private init() {
        
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            
            Task { @MainActor in
                print("path.status: ", path.status)
                self.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }
}
