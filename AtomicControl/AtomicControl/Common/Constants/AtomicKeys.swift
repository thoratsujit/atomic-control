//
//  AtomicKeys.swift
//  AtomicControl
//
//  Created by Sujit Thorat on 13/09/24.
//

import Foundation

enum AtomicKeys: String {
    case apiKey = "apiKey"
    case userName = "userName"
    case homeName = "homeName"
    case authToken = "authToken"
    case refreshToken = "refreshToken"
    case isUserOnboarded = "isUserOnboarded"
    case deviceList = "deviceList"
    
    var value: String {
        return "fbx-atomic-\(self.rawValue)"
    }
}
