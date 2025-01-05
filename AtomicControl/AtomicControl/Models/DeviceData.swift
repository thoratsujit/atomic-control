//
//  DeviceData.swift
//  AtomicControl
//
//  Created by Sujit Thorat on 03/09/24.
//

import Foundation

// MARK: Get Devices List Response
struct DeviceData: Decodable {
    let status: String
    let message: DeviceMessage
}

struct DeviceMessage: Decodable {
    let devicesList: [Device]
    
    enum CodingKeys: String, CodingKey {
        case devicesList = "devices_list"
    }
}

struct Device: Codable, Identifiable, Equatable {
    let id = UUID()
    let metadata: Metadata
    let deviceID: String
    let color: String
    let series: String
    let model: String
    let room: String
    let name: String
    
    var state: DeviceState?
    
    enum CodingKeys: String, CodingKey {
        case metadata
        case deviceID = "device_id"
        case color
        case series
        case model
        case room
        case name
        case state
    }
}

extension Device {
    static func == (lhs: Device, rhs: Device) -> Bool {
        return lhs.deviceID == rhs.deviceID
    }
}

struct Metadata: Codable {
    let ssid: String
}
