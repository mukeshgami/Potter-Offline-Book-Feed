//
//  BookRowView.swift
//  BookFeed
//
//  Created by mukesh.gami on 02/11/25.
//

import SwiftUI

struct BookRowView: View {
    let book: Book
    @StateObject private var imageLoader = ImageLoader()
    
    var body: some View {
        HStack(alignment: .top) {
            Group {
                if let ui = imageLoader.image {
                    Image(uiImage: ui)
                        .resizable()
                        .aspectRatio(2/3, contentMode: .fill)
                        .frame(width: 60, height: 90)
                        .cornerRadius(6)
                } else {
                    Rectangle()
                        .foregroundColor(.gray.opacity(0.3))
                        .frame(width: 60, height: 90)
                        .cornerRadius(6)
                        .overlay(ProgressView().scaleEffect(0.7))
                }
            }
            .onAppear {
                imageLoader.load(from: URL(string: book.cover)!)
            }
            .onDisappear {
                imageLoader.cancel()
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(book.title).font(.headline)
                HStack {
                    Text(book.releaseDate)
                }.font(.caption).foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 8)
    }
}
