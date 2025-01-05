//
//  DeviceControlValueProvider.swift
//  AtomicControl
//
//  Created by Sujit Thorat on 25/09/24.
//

import WidgetKit

@available(iOSApplicationExtension 18.0, *)
struct DeviceControlValueProvider: AppIntentControlValueProvider {
    
    func currentValue(configuration: ControlDeviceConfiguration) async throws -> DeviceItem {
        await WidgetVM.shared.fetchDeviceState(by: configuration.device?.id ?? "")
        let devices = WidgetVM.shared.devices
        guard let device = devices.first(where: {$0.deviceID == configuration.device?.id}),
              let state = device.state else {
            return DeviceItem(deviceIntentEntity: placeholder(), value: false)
        }
        return DeviceItem(deviceIntentEntity: .init(id: device.deviceID,
                                                    name: device.name,
                                                    room: device.room),
                          value: state.isPoweredOn)
    }
    
    func placeholderValue(configuration: ControlDeviceConfiguration) async throws -> DeviceItem {
        return .init(deviceIntentEntity: configuration.device ?? placeholder(),
                     value: false)
    }
    
    func previewValue(configuration: ControlDeviceConfiguration) -> DeviceItem {
        return .init(deviceIntentEntity: configuration.device ?? placeholder(),
                     value: false)
    }
    
    private func placeholder() -> DeviceEntity {
        return .init(id: "",
                     name: "Smart Fan",
                     room: "Living Room")
    }
}
