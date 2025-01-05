//
//  AppIntents.swift
//  AtomicControl
//
//  Created by Sujit Thorat on 25/09/24.
//

import AppIntents

struct DevicePowerIntent: AppIntent {
    static var title: LocalizedStringResource = "Turn device ON/OFF"
    static var description: IntentDescription = "Turn device(s) either on or off."
    
    init() {}
    
    init(device: DeviceEntity, value: Bool) {
        self.device = device
        self.value = value
    }
    
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

struct SpeedIntent: AppIntent {
    
    static var title: LocalizedStringResource = "Adjust fan speed"
    static var description: IntentDescription = "Set the fan speed to your desired level."
    
    init() {}
    
    init(device: DeviceEntity, speed: Int) {
        self.device = device
        self.speed = speed
    }
    
    @Parameter(title: "Device")
    var device: DeviceEntity
    
    @Parameter(title: "Speed", description: "1-6", inclusiveRange: (1, 6))
    var speed: Int
    
    func perform() async throws -> some IntentResult {
        await WidgetVM.shared.controlSpeed(with: .speed,
                                           and: device.id,
                                           speed: speed)
        return .result()
    }
    
    static var parameterSummary: some ParameterSummary {
        Summary("Set \(\.$device) speed to \(\.$speed) ")
    }
}

