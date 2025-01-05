//
//  ConfigurationIntent.swift
//  AtomicControl
//
//  Created by Sujit Thorat on 25/09/24.
//

import AppIntents

struct ConfigurationIntent: WidgetConfigurationIntent {
    
    static var title: LocalizedStringResource = "Select a device"
    static let description: IntentDescription = "Quickly control your favorite device with just a simple tap."
    
    @Parameter(title: "Device")
    var device: DeviceEntity?
}
