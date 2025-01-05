//
//  KeychainManager.swift
//  AtomicControl
//
//  Created by Sujit Thorat on 13/09/24.
//

import Foundation
import Security

// KeychainManager class to handle Keychain operations
class KeychainManager {
    
    static let shared = KeychainManager()
    
    private init() {}
    
    // TODO: Move to environment variables
    private let accessGroup: String = "983VYQQND2.com.fabex3d.com.AtomicControl.shared"
    private let atomicService: String = "com.fabex3d.com.AtomicControl.service"
    
    // MARK: - Save Data to Keychain
    func save(value: String, forKey key: AtomicKeys) throws {
        guard let data = value.data(using: .utf8) else {
            throw KeychainError.dataConversionFailed
        }
        
        // Create a query to save data
        let attributes: [String: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: atomicService,
            kSecAttrAccount: key.value,
            kSecAttrAccessGroup: accessGroup,
            kSecValueData: data,
            kSecAttrSynchronizable: kCFBooleanTrue!
        ] as [String: Any]
        
        // Delete any existing item
        SecItemDelete(attributes as CFDictionary)
        // Add data to Keychain
        let status = SecItemAdd(attributes as CFDictionary, nil)
        if status != errSecSuccess {
            if let errorMessage = SecCopyErrorMessageString(status, nil) {
                throw KeychainError.unknownError(errorMessage as String)
            }
            throw KeychainError.unhandledError(status: status)
        }
    }
    
    // Retrieve a value from Keychain
    func retrieveValue(forKey key: AtomicKeys) throws -> String {
        // Create a query to retrieve data
        let attributes: [String: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: atomicService,
            kSecAttrAccount: key.value,
            kSecAttrAccessGroup: accessGroup,
            kSecReturnData: kCFBooleanTrue!,
            kSecMatchLimit: kSecMatchLimitOne,
            kSecAttrSynchronizable: kCFBooleanTrue!
        ] as [String: Any]
        
        var dataTypeRef: CFTypeRef?
        let status = SecItemCopyMatching(attributes as CFDictionary, &dataTypeRef)
        
        if status != errSecSuccess {
            if let errorMessage = SecCopyErrorMessageString(status, nil) {
                throw KeychainError.unknownError(errorMessage as String)
            }
            throw KeychainError.unhandledError(status: status)
        }
        
        guard status == errSecSuccess,
              let data = dataTypeRef as? Data,
              let value = String(data: data, encoding: .utf8) else {
            throw KeychainError.unexpectedItemData
        }
        return value
    }
    
    // Update a value in Keychain
    func update(value: String, forKey key: AtomicKeys) throws {
        guard let data = value.data(using: .utf8) else {
            throw KeychainError.dataConversionFailed
        }
        
        // Create a query to update data
        let attributes: [String: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: atomicService,
            kSecAttrAccount: key.value,
            kSecAttrAccessGroup: accessGroup,
            kSecAttrSynchronizable: kCFBooleanTrue!
        ] as [String: Any]
        
        // Create an update dictionary
        let attributesToUpdate: [String: Any] = [
            kSecValueData: data
        ] as [String: Any]
        
        let status = SecItemUpdate(attributes as CFDictionary, attributesToUpdate as CFDictionary)
        
        if status != errSecSuccess {
            if let errorMessage = SecCopyErrorMessageString(status, nil) {
                throw KeychainError.unknownError(errorMessage as String)
            }
            throw KeychainError.unhandledError(status: status)
        }
    }
    
    // Delete a value from Keychain
    func deleteValue(forKey key: AtomicKeys) -> Bool {
        // Create a query to delete data
        let attributes: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key.value,
            kSecAttrAccessGroup as String: accessGroup
        ]
        
        let status = SecItemDelete(attributes as CFDictionary)
        
        return status == errSecSuccess
    }
    
    func getHeaders(type: HeaderType) -> [String : String] {
        var headers: [String : String] = [:]
        
        do {
            let apiKey = try retrieveValue(forKey: .apiKey)
            
            headers[HeaderKeys.apiKey.rawValue] = apiKey
            
            if type == .accessToken {
                let refreshToken = TokenManager.shared.token
                headers[HeaderKeys.token.rawValue] = "Bearer \(refreshToken)"
            } else {
                let authToken = try retrieveValue(forKey: .authToken)
                headers[HeaderKeys.token.rawValue] = "Bearer \(authToken)"
            }
        } catch {
            return [:]
        }
        return headers
    }
}
