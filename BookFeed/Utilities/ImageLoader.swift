//
//  ImageLoader.swift
//  BookFeed
//
//  Created by mukesh.gami on 01/11/25.
//

import Foundation
import SwiftUI
import Combine

final class ImageCache {
    
    static let shared = ImageCache()
    private let cache = NSCache<NSString, UIImage>()
    private init() {}
    
    func image(forKey key: String) -> UIImage? {
        cache.object(forKey: key as NSString)
    }
    
    func insertImage(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
}

@MainActor
final class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    private var task: Task<Void, Never>?

    func load(from url: URL?) {
        guard let url = url else { return }
        
        if let cached = ImageCache.shared.image(forKey: url.absoluteString) {
            self.image = cached
            return
        }

        task = Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let ui = UIImage(data: data) {
                    ImageCache.shared.insertImage(ui, forKey: url.absoluteString)
                    self.image = ui
                }
            } catch {
                print("Failed to load image: \(error.localizedDescription)")
            }
        }
    }

    func cancel() {
        task?.cancel()
    }
}
