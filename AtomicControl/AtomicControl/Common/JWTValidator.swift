//
//  JWTValidator.swift
//  AtomicControl
//
//  Created by Sujit Thorat on 14/09/24.
//

import Foundation

struct JWTValidator {
    
    /// Decodes a base64Url encoded string (used in JWT)
    /// - Parameter base64Url: The base64Url encoded string
    /// - Returns: Decoded `Data` if successful, otherwise `nil`
    private func base64UrlDecode(_ base64Url: String) -> Data? {
        var base64 = base64Url
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        
        let paddedLength = base64.count + (4 - base64.count % 4) % 4
        base64 = base64.padding(toLength: paddedLength, withPad: "=", startingAt: 0)
        
        return Data(base64Encoded: base64)
    }
    
    /// Decodes the payload from a JWT token
    /// - Parameter token: The JWT token as a string
    /// - Returns: A dictionary representing the payload or `nil` if decoding fails
    private func decodeJWTPayload(token: String) -> [String: Any]? {
        let segments = token.split(separator: ".")
        guard segments.count == 3 else {
            print("Invalid JWT format")
            return nil
        }
        
        let payloadSegment = String(segments[1])
        
        guard let decodedData = base64UrlDecode(payloadSegment) else {
            print("Failed to decode base64")
            return nil
        }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: decodedData, options: []) as? [String: Any] {
                return json
            } else {
                print("Failed to parse JSON")
                return nil
            }
        } catch {
            print("Error decoding JSON: \(error)")
            return nil
        }
    }
    
    /// Checks if the JWT token is expired based on the `exp` claim in the payload
    /// - Parameter token: The JWT token as a string
    /// - Returns: `true` if the token is expired, `false` otherwise
    func isTokenExpired(token: String) -> Bool {
        guard let payload = decodeJWTPayload(token: token) else {
            print("Failed to decode JWT payload")
            return true // Assuming expired if the payload can't be decoded
        }
        
        if let exp = payload["exp"] as? TimeInterval {
            let expirationDate = Date(timeIntervalSince1970: exp)
            let currentDate = Date()
            return expirationDate <= currentDate // Expired if expiration date is in the past
        } else {
            print("No 'exp' field found in the payload")
            return true // Assuming expired if no expiration time is found
        }
    }
    
    /// Validates if the JWT token is still valid or if it has expired
    /// - Parameter token: The JWT token as a string
    /// - Returns: A boolean indicating whether the token is valid
    func isTokenValid(token: String) -> Bool {
        return !isTokenExpired(token: token)
    }
}
