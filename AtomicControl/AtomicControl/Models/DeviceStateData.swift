//
//  DeviceStateData.swift
//  AtomicControl
//
//  Created by Sujit Thorat on 03/09/24.
//

import Foundation

// MARK: Get Device State Response
struct DeviceStateData: Decodable {
    let status: String
    let message: DeviceStateMessage
}

struct DeviceStateMessage: Decodable {
    let deviceState: [DeviceState]
    
    enum CodingKeys: String, CodingKey {
        case deviceState = "device_state"
    }
}

struct DeviceState: Codable, Equatable {
    let deviceID: String
    let isPoweredOn: Bool
    let lastRecordedSpeed: Int
    let isSleepModeOn: Bool
    let isLedOn: Bool
    let isOnline: Bool
    let timerHours: Int
    let timeElapsedInMins: Int
    let epochSeconds: Int
    let lastRecordedBrightness: Int?
    let lastRecordedColor: String?
    
    var color: String?
    var series: String?
    var model: String?
    var room: String?
    var name: String?
    
    var minutesLeft: Int? {
        return Calendar.current.minutesLeft(until: TimeInterval(epochSeconds))
    }
    
    enum CodingKeys: String, CodingKey {
        case deviceID = "device_id"
        case isPoweredOn = "power"
        case lastRecordedSpeed = "last_recorded_speed"
        case isSleepModeOn = "sleep_mode"
        case isLedOn = "led"
        case isOnline = "is_online"
        case timerHours = "timer_hours"
        case timeElapsedInMins = "timer_time_elapsed_mins"
        case epochSeconds = "ts_epoch_seconds"
        case lastRecordedBrightness = "last_recorded_brightness"
        case lastRecordedColor = "last_recorded_color"
        
        case color
        case series
        case model
        case room
        case name
    }
}
