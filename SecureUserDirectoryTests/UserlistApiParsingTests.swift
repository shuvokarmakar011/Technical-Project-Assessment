//
//  UserlistApiParsingTests.swift
//  SecureUserDirectory
//
//  Created by Shuvo on 4/9/25.
//

import XCTest
import Combine
@testable import SecureUserDirectory

// Mock Network Service
class MockNetworkServiceUserList: NetworkServiceProtocol {
    var response: AnyPublisher<UsersResponse, Error>?
    
    func performRequest<T: Decodable>(_ request: URLRequest) -> AnyPublisher<T, Error> {
        guard let response = response as? AnyPublisher<T, Error> else {
            fatalError("Mock response not set")
        }
        return response
    }
}

// Mock Keychain Helper
class MockKeychainHelperUserList: KeychainHelper {
    override func getToken() -> String? {
        return "mockToken"
    }
}

class UsersViewModelTests: XCTestCase {
    var viewModel: UsersViewModel!
    var mockNetworkService: MockNetworkServiceUserList!
    var mockKeychainHelper: MockKeychainHelperUserList!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkServiceUserList()
        mockKeychainHelper = MockKeychainHelperUserList()
        KeychainHelper.shared = mockKeychainHelper
        viewModel = UsersViewModel(networkService: mockNetworkService)
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        viewModel = nil
        mockNetworkService = nil
        mockKeychainHelper = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testFetchUsersParsesResponse() {
        // Given
        let sampleResponse = UsersResponse(
            page: 1,
            per_page: 6,
            total: 12,
            total_pages: 2,
            data: [
                User(id: 1, email: "george.bluth@reqres.in", first_name: "George", last_name: "Bluth", avatar: "https://reqres.in/img/faces/1-image.jpg")
            ],
            support: UsersResponse.Support(url: "https://reqres.in/#support", text: "Support text")
        )
        mockNetworkService.response = Just(sampleResponse)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        
        // When
        let expectation = XCTestExpectation(description: "Users parsed")
        viewModel.$users
            .dropFirst()
            .sink { users in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.fetchUsers(page: 1)
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(viewModel.users.count, 1, "Should have 1 user")
        XCTAssertEqual(viewModel.users.first?.email, "george.bluth@reqres.in", "User email should match")
        XCTAssertEqual(viewModel.currentPage, 1, "Current page should be 1")
        XCTAssertEqual(viewModel.totalPages, 2, "Total pages should be 2")
        XCTAssertFalse(viewModel.isLoading, "isLoading should be false")
        XCTAssertFalse(viewModel.showErrorAlert, "No error alert should be shown")
    }
}
