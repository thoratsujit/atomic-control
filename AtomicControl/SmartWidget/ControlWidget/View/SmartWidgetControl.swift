//
//  SmartWidgetControl.swift
//  SmartWidget
//
//  Created by Sujit Thorat on 17/09/24.
//

import AppIntents
import SwiftUI
import WidgetKit

@available(iOS 18, *)
struct DeviceItem {
    let deviceIntentEntity: DeviceEntity
    var value: Bool
}

@available(iOSApplicationExtension 18.0, *)
struct SmartWidgetControl: ControlWidget {
    static let kind: String = "com.fabex3d.com.AtomicControl.SmartWidgetControl"
    
    var body: some ControlWidgetConfiguration {
        AppIntentControlConfiguration(kind: SmartWidgetControl.kind,
                                      provider: DeviceControlValueProvider()) { deviceItem in
            ControlWidgetToggle(isOn: deviceItem.value,
                                action: {
                let intent = DeviceControlIntent()
                intent.value = !deviceItem.value
                intent.device = deviceItem.deviceIntentEntity
                return intent
            }()) {
                Label {
                    Text(deviceItem.deviceIntentEntity.name)
                    Text(deviceItem.deviceIntentEntity.room)
                } icon: {
                    Image(systemName: deviceItem.value ? "fan.ceiling.fill" : "fan.ceiling")
                }
                .invalidatableContent()
            } valueLabel: { isOn in
                Text(isOn ? "On" : "Off")
            }
            .tint(.orange)
        }
        .promptsForUserConfiguration()
        .displayName("Atomic Home")
        .description("Quickly control your favourite home devices")
    }
}

@available(iOS 18.0, *)
struct ControlDeviceConfiguration: ControlConfigurationIntent {
    static var title: LocalizedStringResource = "Select a device"
    static let description: IntentDescription = "Quickly turn your favorite device on or off with just a simple tap."
    
    @Parameter(title: "Device")
    var device: DeviceEntity?
}

@available(iOS 18, *)
struct DeviceControlIntent: SetValueIntent {
    static var title: LocalizedStringResource = "Toggle device state"
    static var description: IntentDescription = "Turn device(s) either on or off."
    
    @Parameter(title: "Device")
    var device: DeviceEntity
    
    @Parameter(title: "Power")
    var value: Bool
    
    func perform() async throws -> some IntentResult {
        await WidgetVM.shared.controlPower(with: .isPoweredOn,
                                           and: device.id,
                                           isPoweredOn: value)
        return .result()
    }
    
    static var parameterSummary: some ParameterSummary {
        Summary("Turn \(\.$value) \(\.$device)")
    }
}
