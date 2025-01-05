//
//  WatchConnectivityHelper.swift
//  AtomicControl
//
//  Created by Sujit Thorat on 25/09/24.
//

import Foundation
import WatchConnectivity

final class WatchConnectivityHelper: NSObject, ObservableObject {
    
    @Published private(set) var refreshData: Bool = false
    
    static let shared = WatchConnectivityHelper()
    
    override private init() {
        super.init()
    }
    
    func setupWCSession() {
#if !os(watchOS)
        guard WCSession.isSupported() else {
            return
        }
#endif
        
        WCSession.default.delegate = self
        WCSession.default.activate()
    }
    
    private func canSendToPeer() -> Bool {
#if os(watchOS)
        guard WCSession.default.isCompanionAppInstalled else {
            return false
        }
#else
        guard WCSession.default.isPaired else {
            return false
        }
        
        guard WCSession.default.isWatchAppInstalled else {
            return false
        }
#endif
        
        guard WCSession.default.activationState == .activated else {
            return false
        }
        
        return true
    }
    
    // Generic function to send any Codable object
    func sendData<T: Codable>(object: T, key: AtomicKeys) {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(object)
            if let jsonString = String(data: data, encoding: .utf8) {
                let message = [key.value: jsonString]
                sendMessage(message)
            }
        } catch {
            print("Failed to encode object: \(error)")
        }
    }
    
    // Send a message dictionary
    private func sendMessage(_ message: [String: Any]) {
        guard canSendToPeer() else { return }
        if WCSession.default.isReachable {
            // Interactive messaging
            WCSession.default.sendMessage(message, replyHandler: nil)
        } else {
            // Background messaging
            do {
                try WCSession.default.updateApplicationContext(message)
            } catch {
                print("WatchConnectivityHelper Error: \(error)")
            }
        }
    }
    
    // Update UI from data
    private func update(from message: [String: Any]) {
        if let deviceListString = message[AtomicKeys.deviceList.value] as? String,
           let devices: [Device] = deviceListString.decode(to: [Device].self) {
            DispatchQueue.main.async {
                UserDefaultsManager.shared.save(object: devices, key: .deviceList)
                self.refreshData = true
            }
        } else {
            refreshData = false
        }
    }
}

// MARK: - WCSessionDelegate
extension WatchConnectivityHelper: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        var message: String = "WCSession State "
        switch activationState {
            case .notActivated:
                message += "Not Activated"
            case .inactive:
                message += "Inactive"
            case .activated:
                message += "Activated"
            @unknown default:
                break
        }
        print(message)
    }
    
#if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        // If the person has more than one watch, and they switch,
        // reactivate their session on the new device.
        WCSession.default.activate()
    }
#endif
    
    ///Receive data
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        update(from: applicationContext)
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        update(from: message)
    }
}
