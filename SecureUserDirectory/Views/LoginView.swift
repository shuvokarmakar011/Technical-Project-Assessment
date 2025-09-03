//
//  LoginView.swift
//  SecureUserDirectory
//
//  Created by Shuvo on 3/9/25.
//

/*
 
"email": "eve.holt@reqres.in",
"password": "cityslicka"

 */

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    
    var body: some View {
        NavigationStack {
            if viewModel.isLoggedIn {
                UsersView()
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Logout") {
                                viewModel.logout()
                            }
                            .foregroundColor(.red)
                        }
                    }
            } else {
                VStack(spacing: 20) {
                    Text("Login")
                        .font(.largeTitle)
                    
                    TextField("Email", text: $viewModel.email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    SecureField("Password", text: $viewModel.password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button("Login") {
                        viewModel.login()
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding()
                .navigationTitle("Login")
                .alert("Login Failed", isPresented: $viewModel.showAlert) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text(viewModel.alertMessage)
                }
            }
        }
    }
}
