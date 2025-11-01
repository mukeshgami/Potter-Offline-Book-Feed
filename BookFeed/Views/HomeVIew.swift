//
//  HomeView.swift
//  BookFeed
//
//  Created by mukesh.gami on 01/11/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject var vm: BooksViewModel
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                bookView
                    .padding(.top, vm.isOnline ? 0 : 28)
                
                if !vm.isOnline {
                    HStack(spacing: 8) {
                        Image(systemName: "wifi.slash")
                        Text("You are offline — showing cached data")
                            .lineLimit(1)
                            .truncationMode(.tail)
                        Spacer()
                    }
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.horizontal)
                    .frame(height: 28)
                    .background(Color.red)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(2)
                }
            }
            .navigationTitle("Potter Books")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 10) {
                        if vm.isLoading {
                            ProgressView()
                        }
                        Image(systemName: vm.isOnline ? "wifi" : "wifi.slash")
                            .foregroundColor(vm.isOnline ? .green : .red)
                    }
                }
            }
            .searchable(text: $searchText)
            .onChange(of: searchText) { _, new in vm.search(new) }
            .task { vm.loadInitial() }
            .animation(.easeInOut, value: vm.isOnline)
            .alert(
                "Error",
                isPresented: Binding(
                    get: { vm.errorMessage != nil },
                    set: { _ in vm.errorMessage = nil }
                ),
                actions: {
                    Button("OK", role: .cancel) {
                        vm.errorMessage = nil
                    }
                },
                message: {
                    Text(vm.errorMessage ?? "An unexpected error occurred.")
                }
            )
        }
    }
    
    @ViewBuilder
    var bookView: some View {
        if vm.isLoading && vm.books.isEmpty {
            ProgressView("Loading…")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if vm.books.isEmpty {
            VStack(spacing: 16) {
                Text("No books available")
                if !vm.isOnline {
                    Text("No Internet Connection").foregroundColor(.secondary)
                }
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            List(vm.books) { book in
                BookRowView(book: book)
            }
            .refreshable { vm.refreshTriggered() }
        }
    }
}
