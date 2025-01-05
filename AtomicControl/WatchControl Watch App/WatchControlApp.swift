//
//  WatchControlApp.swift
//  WatchControl Watch App
//
//  Created by Sujit Thorat on 15/09/24.
//

import SwiftUI

@main
struct WatchControl_Watch_AppApp: App {
    
    @WKApplicationDelegateAdaptor var appDelegate: WatchAppDelegate
    @Environment(\.scenePhase) private var scenePhase
    
    private let tokenManager: TokenManager = .shared
    
    var body: some Scene {
        WindowGroup {
            WatchHomeView()
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
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
