//
//  KeychainError.swift
//  AtomicControl
//
//  Created by Sujit Thorat on 16/09/24.
//

import Foundation

enum KeychainError: Error, LocalizedError {
    case dataConversionFailed
    case itemNotFound
    case unableToAddItem
    case unableToUpdateItem
    case unableToDeleteItem
    case unexpectedItemData
    case unhandledError(status: OSStatus)
    case unknownError(String)
    
    var errorDescription: String {
        switch self {
            case .dataConversionFailed:
                return "Data conversion failed."
            case .itemNotFound:
                return "Item not found in Keychain."
            case .unableToAddItem:
                return "Unable to add item to Keychain."
            case .unableToUpdateItem:
                return "Unable to update item in Keychain."
            case .unableToDeleteItem:
                return "Unable to delete item from Keychain."
            case .unexpectedItemData:
                return "Unexpected data found in Keychain."
            case .unhandledError(let status):
                return "Keychain error, \(status.description)."
            case .unknownError(let message):
                return "Keychain error, \(message)"
        }
    }
}
