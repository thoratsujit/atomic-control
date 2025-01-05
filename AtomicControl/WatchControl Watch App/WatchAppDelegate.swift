//
//  WatchAppDelegate.swift
//  AtomicControl
//
//  Created by Sujit Thorat on 25/09/24.
//

import WatchKit

final class WatchAppDelegate: NSObject, WKApplicationDelegate {
    private let listener = UDPListener.shared
    
    func applicationDidFinishLaunching() {
        WatchConnectivityHelper.shared.setupWCSession()
        listener.startListening()
    }
}

