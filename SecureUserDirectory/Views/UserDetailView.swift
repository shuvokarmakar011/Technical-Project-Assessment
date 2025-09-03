//
//  UserDetailView.swift
//  SecureUserDirectory
//
//  Created by Shuvo on 3/9/25.
//

import SwiftUI

struct UserDetailView: View {
    let user: User
    
    var body: some View {
        VStack(spacing: 20) {
            AsyncImage(url: URL(string: user.avatar)) { image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 150, height: 150)
            .clipShape(Circle())
            
            Text(user.fullName)
                .font(.title)
            
            Text(user.email)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .navigationTitle(user.fullName)
        .padding()
    }
}
