//
//  DeviceCell.swift
//  AtomicControl
//
//  Created by Sujit Thorat on 08/09/24.
//

import SwiftUI
import Combine

struct DeviceCell: View {
    
    @ObservedObject var viewModel: DeviceViewModel
    @Binding var device: Device
    
    @State var deviceState: FanState = {
        FanState(deviceID: "",
                 isPoweredOn: false,
                 isLedOn: false,
                 isSleepModeOn: false,
                 speed: .zero,
                 timerHour: .zero,
                 timerMins: .zero,
                 brightness: .zero,
                 cool: false,
                 warm: false,
                 color: "")
    }()
    
    @State private var sliderWorkItem: DispatchWorkItem?
    @State private var isUserInteracting: Bool = false
    
    private var powerButtonIcon: String {
        return deviceState.isPoweredOn ? "power.circle.fill" : "power.circle"
    }
    
    private var ledButtonIcon: String {
        return deviceState.isLedOn ? "lightbulb.fill" : "lightbulb"
    }
    
    private var onlineIcon: String {
        return deviceState.isOnline ? "wifi" : "wifi.slash"
    }
    
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                Image(.atomicFan)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(.leading, 8)
                    .padding(.top, 8)
                    .dropShadow()
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(device.name)
                        .font(.callout).fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    Text(device.room)
                        .font(.footnote)
                    
                    HStack(spacing: 4) {
                        textview(text: Text("\(Image(systemName: onlineIcon))"),
                                 horizontalPadding: 3)
                        if deviceState.isSleepModeOn {
                            textview(text: Text("\(Image(systemName: "moon.fill"))"))
                        }
                        if let timerDisplayString = deviceState.timerDisplayString {
                            textview(text: Text("\(Image(systemName: "timer")) \(timerDisplayString)"))
                        }
//                        if deviceState.timerMins != .zero || deviceState.timerHour != .zero {
//                            textview(text: Text("\(Image(systemName: "timer")) \(deviceState.timerHour.leadingZeroString()):\(deviceState.timerMins.leadingZeroString())"))
//                        }
                        if deviceState.brightness != .zero {
                            textview(text: Text("\(Image(systemName: "light.max")) \(Int(deviceState.brightness))"))
                        }
                    }
                }
                
                Spacer()
            }
            
            Divider()
                .frame(height: 1.6)
                .background(.primary.opacity(0.05))
                .padding(.horizontal, 8)
            HStack {
                SliderView(value: $deviceState.speed, onEditingChanged: { isEditing in
                    isUserInteracting = isEditing
                })
                IconicButton(icon: ledButtonIcon,
                             size: .init(width: 48, height: 48)) {
                    deviceState.isLedOn.toggle()
                    sendUpdateCommand(with: .isLedOn)
                }
                IconicButton(icon: powerButtonIcon,
                             size: .init(width: 48, height: 48)) {
                    deviceState.isPoweredOn.toggle()
                    sendUpdateCommand(with: .isPoweredOn)
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
            .dropShadow()
        }
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .onChange(of: device.state) { status in
            updateDeviceState()
        }
        .onChange(of: deviceState.speed) { status in
            if isUserInteracting {
                handleSliderInput()
            }
        }
        .onFirstAppear {
            updateDeviceState()
        }
    }
    
    @ViewBuilder
    private func textview(text: Text, horizontalPadding: CGFloat = 4) -> some View {
        text
            .font(.caption)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, 2)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 4))
    }
    
    private func handleSliderInput() {
        sliderWorkItem?.cancel()
        
        let workItem = DispatchWorkItem {
            sendUpdateCommand(with: .speed)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)
        
        sliderWorkItem = workItem
    }
    
    private func updateDeviceState() {
        guard let state = device.state else { return }
        deviceState = FanState(deviceID: state.deviceID,
                               isOnline: state.isOnline,
                               isPoweredOn: state.isPoweredOn,
                               isLedOn: state.isLedOn,
                               isSleepModeOn: state.isSleepModeOn,
                               speed: Double(state.lastRecordedSpeed),
                               timerHour: state.timerHours,
                               timerMins: state.timeElapsedInMins,
                               brightness: Double(state.lastRecordedBrightness ?? .zero),
                               cool: false,
                               warm: false)
    }
    
    private func sendUpdateCommand(with controlType: DeviceControlType) {
        Task {
            await viewModel.controlDevice(with: controlType, and: deviceState)
        }
    }
}

struct SliderView: View {
    @Binding var value: Double
    let onEditingChanged: (Bool) -> Void
    
    private let min: Double = 1
    private let max: Double = 6
    private let step: Double = 1
    private let gradient = LinearGradient(colors: [.orange, .yellow, .green, .blue], startPoint: .leading, endPoint: .trailing)
    
    var body: some View {
        Slider(value: $value,
               in: min...max,
               step: step,
               onEditingChanged: { value in
            onEditingChanged(value)
        })
        .tint(.primary)
        .padding()
        .frame(maxHeight: 48)
        .background(.ternaryBackground, in: RoundedRectangle(cornerRadius: 8))
        .onChange(of: value) { state in
            hapticFeedback(.selection)
        }
    }
}
