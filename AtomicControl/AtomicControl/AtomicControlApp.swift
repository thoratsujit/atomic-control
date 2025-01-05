//
//  AtomicControlApp.swift
//  AtomicControl
//
//  Created by Sujit Thorat on 03/09/24.
//

import SwiftUI

@main
struct AtomicControlApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) private var scenePhase
    
    private let tokenManager: TokenManager = .shared
    
    var body: some Scene {
        WindowGroup {
            CoordinatorView()
        }
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
                case .background, .inactive:
                    break
                case .active:
                    tokenManager.ensureTokenValidity()
                default:
                    break
            }
        }
    }
}
