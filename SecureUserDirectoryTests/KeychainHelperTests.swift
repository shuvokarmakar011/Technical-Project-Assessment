//
//  KeychainHelperTests.swift
//  SecureUserDirectory
//
//  Created by Shuvo on 4/9/25.
//

import XCTest
@testable import SecureUserDirectory

class KeychainHelperTests: XCTestCase {
    var keychainHelper: KeychainHelper!
    
    override func setUp() {
        super.setUp()
        keychainHelper = KeychainHelper()
        // Clear any existing token to ensure a clean state
        keychainHelper.deleteToken()
    }
    
    override func tearDown() {
        // Clean up Keychain after each test
        keychainHelper.deleteToken()
        keychainHelper = nil
        super.tearDown()
    }
    
    func testSaveAndGetToken() {
        // Given
        let token = "testToken123"
        
        // When
        keychainHelper.saveToken(token)
        let retrievedToken = keychainHelper.getToken()
        
        // Then
        XCTAssertEqual(retrievedToken, token, "Retrieved token should match the saved token")
    }
    
    func testGetTokenWhenNotSet() {
        // Given
        // No token is saved (ensured by setUp)
        
        // When
        let retrievedToken = keychainHelper.getToken()
        
        // Then
        XCTAssertNil(retrievedToken, "Retrieved token should be nil when no token is saved")
    }
    
    func testDeleteToken() {
        // Given
        let token = "testToken123"
        keychainHelper.saveToken(token)
        
        // Verify token exists before deletion
        let tokenBeforeDeletion = keychainHelper.getToken()
        XCTAssertEqual(tokenBeforeDeletion, token, "Token should exist before deletion")
        
        // When
        keychainHelper.deleteToken()
        let retrievedToken = keychainHelper.getToken()
        
        // Then
        XCTAssertNil(retrievedToken, "Retrieved token should be nil after deletion")
    }
    
    func testSaveTokenOverwritesExistingToken() {
        // Given
        let firstToken = "firstToken"
        let secondToken = "secondToken"
        keychainHelper.saveToken(firstToken)
        
        // Verify first token
        let firstRetrievedToken = keychainHelper.getToken()
        XCTAssertEqual(firstRetrievedToken, firstToken, "First token should be retrieved correctly")
        
        // When
        keychainHelper.saveToken(secondToken)
        let secondRetrievedToken = keychainHelper.getToken()
        
        // Then
        XCTAssertEqual(secondRetrievedToken, secondToken, "Second token should overwrite the first token")
        XCTAssertNotEqual(secondRetrievedToken, firstToken, "Second token should not match the first token")
    }
}
