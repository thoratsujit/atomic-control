//
//  NetworkReachabilityManager.swift
//  AtomicControl
//
//  Created by Sujit Thorat on 24/09/24.
//

import Foundation
import Network

typealias Reachability = NetworkReachabilityManager

class NetworkReachabilityManager: ObservableObject {
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue.global(qos: .background)
    
    @Published private(set) var isConnected: Bool = true
    @Published private(set) var isConnectedViaWiFi: Bool = false
    
    init() {
        startMonitoring()
    }
    
    func startMonitoring() {
        monitor.start(queue: queue)
        
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                // Check if the device is connected to the network
                self.isConnected = (path.status == .satisfied)
                // Determine if the connection is via Wi-Fi
                self.isConnectedViaWiFi = (path.usesInterfaceType(.wifi))
            }
        }
    }
    
    func stopMonitoring() {
        monitor.cancel()
    }
    
    deinit {
        stopMonitoring()
    }
}
