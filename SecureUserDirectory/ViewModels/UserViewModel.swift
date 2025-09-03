//
//  UserViewModel.swift
//  SecureUserDirectory
//
//  Created by Shuvo on 3/9/25.
//

import Foundation
import Combine

class UsersViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var showErrorAlert: Bool = false
    @Published var errorMessage: String = ""
    
    private let networkService: NetworkServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
    
    func fetchUsers() {
        guard let url = URL(string: "https://reqres.in/api/users?page=1") else {
            showError("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("reqres-free-v1", forHTTPHeaderField: "x-api-key")
        if let token = KeychainHelper.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            showError("No session token found. Please log in again.")
            return
        }
        
        networkService.performRequest(request)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.showError(error.localizedDescription)
                }
            } receiveValue: { [weak self] (response: UsersResponse) in
                self?.users = response.data
            }
            .store(in: &cancellables)
    }
    
    private func showError(_ message: String) {
        errorMessage = message
        showErrorAlert = true
    }
}
