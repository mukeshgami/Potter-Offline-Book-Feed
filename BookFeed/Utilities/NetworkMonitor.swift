//
//  NetworkMonitor.swift
//  BookFeed
//
//  Created by mukesh.gami on 01/11/25.
//

import Foundation
import Network
import Combine

protocol NetworkMonitorProtocol: AnyObject, ObservableObject {
    var isConnected: Bool { get }
    var isConnectedPublisher: Published<Bool>.Publisher { get }
}

@MainActor
final class NetworkMonitor: ObservableObject, NetworkMonitorProtocol {
    
    static let shared = NetworkMonitor()
    @Published private(set) var isConnected: Bool = true
    var isConnectedPublisher: Published<Bool>.Publisher { $isConnected }

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitorQueue")

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            Task { @MainActor in
                self.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }
}
