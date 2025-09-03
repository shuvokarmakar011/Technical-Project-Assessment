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
            List(viewModel.users) { user in
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
            }
            .refreshable {
                viewModel.refreshUsers()
            }
            .navigationTitle("Users")
            .onAppear {
                viewModel.fetchUsers()
            }
            .alert("Error", isPresented: $viewModel.showErrorAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
}
