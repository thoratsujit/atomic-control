//
//  TokenManager.swift
//  AtomicControl
//
//  Created by Sujit Thorat on 14/09/24.
//

import Foundation

class TokenManager {
    
    static let shared: TokenManager = TokenManager()
    
    private var tokenValiator: JWTValidator = JWTValidator()
    private(set) var token: String = ""
    
    private init() { }
    
    private func fetchToken() {
        Task {
            do {
                let response = try await NetworkService.shared.execute(with: RefreshTokenURI())
                
                await MainActor.run {
                    let refreshToken = response.message.refreshToken
                    token = refreshToken
                    saveInKeychain(token: refreshToken)
                }
            } catch let error as NetworkError {
                print("AccessToken Error: ", error.message)
            }
        }
    }
    
    // TODO: Error handling
    private func saveInKeychain(token: String) {
        do {
            try KeychainManager.shared.save(value: token, forKey: .refreshToken)
        } catch let error as KeychainError {
            print("TokenManager: ",error.errorDescription as Any)
        } catch {
            print("TokenManager: ",error.localizedDescription)
        }
    }
    
    func ensureTokenValidity() {
        do {
            let refreshToken = try KeychainManager.shared.retrieveValue(forKey: .refreshToken)
            token = refreshToken
            if !tokenValiator.isTokenValid(token: token) {
                fetchToken()
            }
        } catch let error as KeychainError {
            print("TokenManager: ",error.errorDescription as Any)
            fetchToken()
        } catch {
            print("TokenManager: ",error.localizedDescription)
            fetchToken()
        }
    }
}
