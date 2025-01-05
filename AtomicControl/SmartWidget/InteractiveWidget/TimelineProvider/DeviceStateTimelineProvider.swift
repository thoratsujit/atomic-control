//
//  DeviceStateTimelineProvider.swift
//  AtomicControl
//
//  Created by Sujit Thorat on 22/09/24.
//

import SwiftUI
import WidgetKit
import AppIntents

struct DeviceEntry: TimelineEntry {
    var date: Date
    let device: Device
}

struct DeviceStateTimelineProvider: AppIntentTimelineProvider {
    
    typealias Entry = DeviceEntry
    typealias Intent = ConfigurationIntent
    
    func placeholder(in context: Context) -> DeviceEntry {
        guard let device = WidgetVM.shared.devices.first else {
            return .init(date: .now, device: mockDevice1)
        }
        return .init(date: .now, device: device)
    }
    
    func snapshot(for configuration: ConfigurationIntent, in context: Context) async -> DeviceEntry {
        let deviceID = configuration.device?.id ?? ""
        guard let device = WidgetVM.shared.devices.first(where: { $0.deviceID == deviceID }) else {
            return .init(date: .now, device: mockDevice1)
        }
        return .init(date: .now, device: device)
    }
    
    func timeline(for configuration: ConfigurationIntent, in context: Context) async -> Timeline<DeviceEntry> {
        let deviceID = configuration.device?.id ?? ""
        
        await WidgetVM.shared.fetchDeviceState(by: deviceID)
        
        let devices = WidgetVM.shared.devices
        
        if let device = devices.first(where: { $0.deviceID == deviceID }) {
            return Timeline(entries: [DeviceEntry(date: .now, device: device)],
                            policy: .atEnd)
        }
        
        return Timeline(entries: [DeviceEntry(date: .now, device: mockDevice1)], policy: .atEnd)
    }
}
