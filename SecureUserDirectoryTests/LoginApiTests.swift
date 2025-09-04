//
//  LoginApiTests.swift
//  SecureUserDirectory
//
//  Created by Shuvo on 4/9/25.
//

import XCTest
import Combine
@testable import SecureUserDirectory

// Mock Network Service
class MockNetworkService: NetworkServiceProtocol {
    var result: AnyPublisher<LoginResponse, Error>?
    
    func performRequest<T: Decodable>(_ request: URLRequest) -> AnyPublisher<T, Error> {
        guard let result = result as? AnyPublisher<T, Error> else {
            fatalError("Mock result not set")
        }
        return result
    }
}

// Mock Keychain Helper
class MockKeychainHelper: KeychainHelper {
    var token: String?
    
    override func saveToken(_ token: String) {
        self.token = token
    }
    
    override func getToken() -> String? {
        return token
    }
    
    override func deleteToken() {
        token = nil
    }
}

class LoginViewModelTests: XCTestCase {
    var viewModel: LoginViewModel!
    var mockNetworkService: MockNetworkService!
    var mockKeychainHelper: MockKeychainHelper!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        mockKeychainHelper = MockKeychainHelper()
        KeychainHelper.shared = mockKeychainHelper
        viewModel = LoginViewModel(networkService: mockNetworkService)
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        viewModel = nil
        mockNetworkService = nil
        mockKeychainHelper = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testLoginSuccess() {
        // Given
        let expectedToken = "QpwL5tke4Pnpja7X4"
        viewModel.email = "eve.holt@reqres.in"
        viewModel.password = "cityslicka"
        let response = LoginResponse(token: expectedToken)
        mockNetworkService.result = Just(response)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        
        // Expectations
        let loginExpectation = XCTestExpectation(description: "Login completes successfully")
        var receivedToken: String?
        
        // When
        viewModel.$isLoggedIn
            .dropFirst()
            .sink { isLoggedIn in
                if isLoggedIn {
                    receivedToken = self.mockKeychainHelper.getToken()
                    loginExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.login()
        
        // Then
        wait(for: [loginExpectation], timeout: 1.0)
        XCTAssertTrue(viewModel.isLoggedIn, "isLoggedIn should be true after successful login")
        XCTAssertEqual(receivedToken, expectedToken, "Saved token should match expected token")
        XCTAssertFalse(viewModel.showAlert, "showAlert should be false on success")
    }
    
    func testLoginFailureInvalidCredentials() {
        // Given
        viewModel.email = "invalid@example.com"
        viewModel.password = "wrong"
        let error = URLError(.badServerResponse)
        mockNetworkService.result = Fail(error: error)
            .eraseToAnyPublisher()
        
        // Expectations
        let alertExpectation = XCTestExpectation(description: "Alert shown on failure")
        var receivedErrorMessage: String?
        
        // When
        viewModel.$showAlert
            .dropFirst() // Skip initial value
            .sink { showAlert in
                if showAlert {
                    receivedErrorMessage = self.viewModel.alertMessage
                    alertExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.login()
        
        // Then
        wait(for: [alertExpectation], timeout: 1.0)
        XCTAssertFalse(viewModel.isLoggedIn, "isLoggedIn should be false after failed login")
        XCTAssertTrue(viewModel.showAlert, "showAlert should be true on failure")
        XCTAssertEqual(receivedErrorMessage, error.localizedDescription, "Alert message should match error description")
        XCTAssertNil(mockKeychainHelper.getToken(), "No token should be saved on failure")
    }
}
