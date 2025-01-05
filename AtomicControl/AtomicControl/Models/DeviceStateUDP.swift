//
//  DeviceStateUDP.swift
//  AtomicControl
//
//  Created by Sujit Thorat on 05/09/24.
//

import Foundation

struct DeviceStateUDP: Codable {
    let deviceID: String
    let messageID: String?
    let state: String?
    
    enum CodingKeys: String, CodingKey {
        case deviceID = "device_id"
        case messageID = "message_id"
        case state = "state_string"
    }
}
