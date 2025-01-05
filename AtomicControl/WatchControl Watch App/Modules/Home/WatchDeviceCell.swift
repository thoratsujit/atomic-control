//
//  WatchDeviceCell.swift
//  WatchControl Watch App
//
//  Created by Sujit Thorat on 15/09/24.
//

import SwiftUI

struct WatchDeviceCell: View {
    @ObservedObject var viewModel: WatchControlVM
    @Binding var device: Device
    @State private var sliderWorkItem: DispatchWorkItem?
    @State private var isUserInteracting: Bool = false
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
    
    private let fanSpeedRange: ClosedRange<Double> = 0...6
    private let step: Double = 1
    
    private var powerButtonIcon: String {
        return deviceState.isPoweredOn ? "power.circle.fill" : "power.circle"
    }
    
    private var onlineIcon: String {
        return deviceState.isOnline ? "wifi" : "wifi.slash"
    }
    
    var body: some View {
        VStack {
            HStack(spacing: .zero) {
                VStack(alignment: .leading, spacing: .zero) {
                    Text(device.name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                    Text(device.room)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Spacer(minLength: .zero)
                
                Button {
                    deviceState.isPoweredOn.toggle()
                    sendUpdateCommand(with: .isPoweredOn)
                } label: {
                    Image(systemName: powerButtonIcon)
                        .resizable()
                        .frame(width: 28, height: 28)
                        .padding(4)
                        .background(.tertiary, in: RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
            }
            .padding(.top)
            .padding(.horizontal)
            
            HStack(spacing: 1) {
                textview(text: Text(Image(systemName: onlineIcon)))
                if deviceState.isSleepModeOn {
                    textview(text: Text(Image(systemName: "moon.fill")),
                             horizontalPadding: 2.5)
                }
                if let timerDisplayString = deviceState.timerDisplayString {
                    textview(text: Text("\(Image(systemName: "timer")) \(timerDisplayString)"))
                }
                if deviceState.isLedOn {
                    if deviceState.brightness != .zero {
                        textview(text: Text("\(Image(systemName: "light.max"))\(Int(deviceState.brightness))"))
                    } else {
                        textview(text: Text(Image(systemName: "light.max")))
                    }
                }
                Spacer(minLength: .zero)
            }
            .padding(.horizontal)
            
            Slider(value: $deviceState.speed,
                   in: fanSpeedRange,
                   step: step) { isEditing in
                isUserInteracting = isEditing
            }
                   .tint(.primary)
        }
        .background(.indigo.gradient, in: RoundedRectangle(cornerRadius: 16))
        .onChange(of: device.state) {
            updateDeviceState()
        }
        .onChange(of: deviceState.speed) { oldValue, newValue in
            /// Handling zero case
            if oldValue == .zero { return }
            if newValue == .zero {
                deviceState.speed = 1
                return
            }
            if isUserInteracting {
                handleSliderInput()
            }
        }
        .onFirstAppear {
            updateDeviceState()
        }
    }
    
    @ViewBuilder
    private func textview(text: Text, horizontalPadding: CGFloat = 2) -> some View {
        text
            .font(.footnote).fontWeight(.semibold)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, 2)
            .background(.tertiary, in: RoundedRectangle(cornerRadius: 4))
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
