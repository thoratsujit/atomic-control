//
//  SmartDeviceWidget.swift
//  SmartWidget
//
//  Created by Sujit Thorat on 17/09/24.
//

import WidgetKit
import SwiftUI
import AppIntents

struct SmartDeviceWidget: Widget {
    static let kind: String = "com.fabex3d.com.AtomicControl.SmartDeviceWidget"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: SmartDeviceWidget.kind,
                               intent: ConfigurationIntent.self,
                               provider: DeviceStateTimelineProvider()) { entry in
            MediumWidgetEntryView(device: entry.device)
        }
                               .configurationDisplayName("Quick Actions")
                               .description("Quickly control your favourite home device")
                               .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    SmartDeviceWidget()
} timeline: {
    DeviceEntry(date: .now, device: mockDevice1)
    DeviceEntry(date: .now, device: mockDevice2)
}

let mockDevice1: Device = Device(metadata: Metadata(ssid: "wifiname"),
                              deviceID: "a0764ee4210c",
                              color: "Pearl White",
                              series: "R1",
                              model: "renesa+",
                              room: "Living Room",
                              name: "Smart Fan",
                              state: DeviceState(deviceID: "a0764ee4210c",
                                                 isPoweredOn: false,
                                                 lastRecordedSpeed: 2,
                                                 isSleepModeOn: false,
                                                 isLedOn: false,
                                                 isOnline: true,
                                                 timerHours: 0,
                                                 timeElapsedInMins: 0,
                                                 epochSeconds: 1725815661,
                                                 lastRecordedBrightness: nil,
                                                 lastRecordedColor: nil,
                                                 color: nil,
                                                 series: nil,
                                                 model: nil,
                                                 room: nil,
                                                 name: nil))
let mockDevice2: Device = Device(metadata: Metadata(ssid: "wifiname"),
                                 deviceID: "a0764ee4210c",
                                 color: "Pearl White",
                                 series: "R1",
                                 model: "renesa+",
                                 room: "Living Room",
                                 name: "Smart Fan",
                                 state: DeviceState(deviceID: "a0764ee4210c",
                                                    isPoweredOn: true,
                                                    lastRecordedSpeed: 4,
                                                    isSleepModeOn: false,
                                                    isLedOn: false,
                                                    isOnline: true,
                                                    timerHours: 0,
                                                    timeElapsedInMins: 0,
                                                    epochSeconds: 1725815661,
                                                    lastRecordedBrightness: nil,
                                                    lastRecordedColor: nil,
                                                    color: nil,
                                                    series: nil,
                                                    model: nil,
                                                    room: nil,
                                                    name: nil))


