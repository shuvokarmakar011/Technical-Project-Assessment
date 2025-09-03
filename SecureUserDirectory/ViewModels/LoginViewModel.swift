//
//  LoginViewModel.swift
//  SecureUserDirectory
//
//  Created by Shuvo on 3/9/25.
//

import Foundation
import Combine

class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoggedIn: Bool = false
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    private let networkService: NetworkServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
    
    func login() {
        guard let url = URL(string: "https://reqres.in/api/login") else {
            showError("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("reqres-free-v1", forHTTPHeaderField: "x-api-key")
        
        let body: [String: String] = ["email": email, "password": password]
        request.httpBody = try? JSONEncoder().encode(body)
        
        networkService.performRequest(request)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.showError(error.localizedDescription)
                }
            } receiveValue: { [weak self] (response: LoginResponse) in
                KeychainHelper.shared.saveToken(response.token)
                self?.isLoggedIn = true
            }
            .store(in: &cancellables)
    }
    
    func logout() {
        KeychainHelper.shared.deleteToken()
        isLoggedIn = false
        email = ""
        password = ""
    }
    
    func getAuthToken() -> String? {
        return KeychainHelper.shared.getToken()
    }
    
    private func showError(_ message: String) {
        alertMessage = message
        showAlert = true
    }
}

struct LoginResponse: Decodable {
    let token: String
}
