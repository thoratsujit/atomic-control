//
//  AuthData.swift
//  AtomicControl
//
//  Created by Sujit Thorat on 03/09/24.
//

import Foundation

// MARK: Get refresh token response
struct AuthData: Decodable {
    let status: String
    let message: TokenMessage
}

struct TokenMessage: Decodable {
    let refreshToken: String
    
    enum CodingKeys: String, CodingKey {
        case refreshToken = "access_token"
    }
}
