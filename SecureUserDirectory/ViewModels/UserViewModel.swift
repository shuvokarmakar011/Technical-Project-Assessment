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
    @Published var currentPage: Int = 1
    @Published var totalPages: Int = 1
    @Published var isLoading: Bool = false
    
    private let networkService: NetworkServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
    
    func fetchUsers(page: Int = 1, isRefresh: Bool = false) {
        guard !isLoading else { return } // Prevent multiple simultaneous requests
        isLoading = true
        
        guard let url = URL(string: "https://reqres.in/api/users?page=\(page)") else {
            showError("Invalid URL")
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("reqres-free-v1", forHTTPHeaderField: "x-api-key")
        if let token = KeychainHelper.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            showError("No session token found. Please log in again.")
            isLoading = false
            return
        }
        
        networkService.performRequest(request)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.showError(error.localizedDescription)
                }
            } receiveValue: { [weak self] (response: UsersResponse) in
                guard let self = self else { return }
                if isRefresh || page == 1 {
                    self.users = response.data // Replace for refresh or first page
                } else {
                    self.users.append(contentsOf: response.data) // Append for pagination
                }
                self.currentPage = response.page
                self.totalPages = response.total_pages
            }
            .store(in: &cancellables)
    }
    
    func refreshUsers() {
        fetchUsers(page: 1, isRefresh: true)
    }
    
    func loadNextPage() {
        if currentPage < totalPages {
            fetchUsers(page: currentPage + 1)
        }
    }
    
    private func showError(_ message: String) {
        errorMessage = message
        showErrorAlert = true
    }
}
