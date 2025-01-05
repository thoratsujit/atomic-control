//
//  AppDelegate.swift
//  AtomicControl
//
//  Created by Sujit Thorat on 04/09/24.
//

import UIKit
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    
    private let listener = UDPListener.shared
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        WatchConnectivityHelper.shared.setupWCSession()
        listener.startListening()
        return true
    }
}
