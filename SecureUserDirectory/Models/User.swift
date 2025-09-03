//
//  UserModel.swift
//  SecureUserDirectory
//
//  Created by Shuvo on 3/9/25.
//

import Foundation

struct User: Decodable, Identifiable {
    let id: Int
    let email: String
    let first_name: String
    let last_name: String
    let avatar: String
    
    var fullName: String {
        "\(first_name) \(last_name)"
    }
}

struct UsersResponse: Decodable {
    let page: Int
    let per_page: Int
    let total: Int
    let total_pages: Int
    let data: [User]
    let support: Support?
    
    struct Support: Decodable {
        let url: String
        let text: String
    }
}
