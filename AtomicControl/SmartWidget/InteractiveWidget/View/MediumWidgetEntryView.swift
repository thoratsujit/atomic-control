//
//  MediumWidgetEntryView.swift
//  AtomicControl
//
//  Created by Sujit Thorat on 25/09/24.
//

import SwiftUI
import WidgetKit

struct MediumWidgetEntryView : View {
    var device: Device
    
    var body: some View {
        VStack(spacing: .zero) {
            if let state = device.state {
                Text(device.name)
                    .font(.caption)
                
                ProgressView(value: progressValue(speed: state.lastRecordedSpeed))
                    .progressViewStyle(.circular)
                    .tint(state.isPoweredOn ? .green : .gray)
                    .rotationEffect(.degrees(180))
                    .overlay(alignment: .center, content: {
                        Button(intent: DevicePowerIntent(device: deviceEntity(),
                                                         value: !state.isPoweredOn)) {
                            Text(Image(systemName: state.isPoweredOn ? "power.circle.fill" : "power.circle"))
                                .font(.largeTitle)
                                .monospaced()
                                .padding()
                                .background(.buttonBackground, in: Circle())
                        }
                                                         .buttonStyle(.plain)
                    })
                    .frame(minWidth: 90, minHeight: 90)
                    .padding(4)
                    .invalidatableContent()
                HStack {
                    Button(intent: SpeedIntent(device: deviceEntity(),
                                               speed: decrease(speed: state.lastRecordedSpeed))) {
                        Text(Image(systemName: "minus"))
                            .font(.headline)
                            .monospaced()
                            .padding(.horizontal)
                            .padding(.vertical, 2)
                            .background(.buttonBackground, in: RoundedRectangle(cornerRadius: 6))
                    }
                    
                    Text("\(state.lastRecordedSpeed)")
                        .monospaced()
                        .contentTransition(.numericText(value: Double(state.lastRecordedSpeed)))
                        .invalidatableContent()
                    
                    Button(intent: SpeedIntent(device: deviceEntity(),
                                               speed: increase(speed: state.lastRecordedSpeed))) {
                        Text(Image(systemName: "plus"))
                            .font(.headline)
                            .monospaced()
                            .padding(.horizontal)
                            .padding(.vertical, 2)
                            .background(.buttonBackground, in: RoundedRectangle(cornerRadius: 6))
                    }
                }
                .buttonStyle(.plain)
            } else {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 32, height: 32)
                    .padding(8)
                    .background(.buttonBackground, in: RoundedRectangle(cornerRadius: 8))
                    .padding(.bottom, 16)
                Text("Tap to Refresh")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .padding(6)
                    .background(.buttonBackground, in: RoundedRectangle(cornerRadius: 8))
            }
        }
        .containerBackground(.widgetBackground, for: .widget)
    }
    
    private func increase(speed: Int) -> Int {
        return min(speed + 1, 6)
    }
    
    private func decrease(speed: Int) -> Int {
        return max(speed - 1, 1)
    }
    
    private func progressValue(speed: Int) -> Double {
        return Double(speed)/6
    }
    
    private func deviceEntity() -> DeviceEntity {
        return .init(id: device.deviceID,
                     name: device.name,
                     room: device.room)
    }
}
