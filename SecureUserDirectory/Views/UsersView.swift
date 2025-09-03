//
//  UsersView.swift
//  SecureUserDirectory
//
//  Created by Shuvo on 3/9/25.
//

import SwiftUI


struct UsersView: View {
    @StateObject private var viewModel = UsersViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.users.indices, id: \.self) { index in
                    let user = viewModel.users[index]
                    NavigationLink(destination: UserDetailView(user: user)) {
                        HStack {
                            AsyncImage(url: URL(string: user.avatar)) { image in
                                image.resizable()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                            
                            VStack(alignment: .leading) {
                                Text(user.fullName)
                                    .font(.headline)
                                Text(user.email)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .onAppear {
                        // Trigger loading next page when reaching the last 3 items
                        if index == viewModel.users.count - 3 && !viewModel.isLoading {
                            viewModel.loadNextPage()
                        }
                    }
                }
                
                // Show loading indicator at the bottom when fetching next page
                if viewModel.isLoading && viewModel.currentPage < viewModel.totalPages {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                }
            }
            .refreshable {
                viewModel.refreshUsers()
            }
            .navigationTitle("Users")
            .onAppear {
                if viewModel.users.isEmpty {
                    viewModel.fetchUsers()
                }
            }
            .alert("Error", isPresented: $viewModel.showErrorAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
}
