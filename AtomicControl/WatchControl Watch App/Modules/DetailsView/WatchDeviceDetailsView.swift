//
//  WatchDeviceDetailsView.swift
//  AtomicControl
//
//  Created by Sujit Thorat on 04/10/24.
//

import SwiftUI

struct WatchDeviceDetailsView: View {
    @ObservedObject var viewModel: WatchControlVM
    
    @State var deviceState: FanState = {
        FanState(deviceID: "",
                 isPoweredOn: false,
                 isLedOn: false,
                 isSleepModeOn: false,
                 speed: .zero,
                 timerHour: .zero,
                 timerMins: .zero,
                 brightness: 10,
                 cool: false,
                 warm: false,
                 color: "")
    }()
    
    @Binding var device: Device
    @State private var sliderWorkItem: DispatchWorkItem?
    @State private var isUserInteracting: Bool = false
    
    @State private var selectedColorMode: ColorMode = .daylight
    @State private var selectedTimer: Int = 1
    
    @State private var showTimer: Bool = false
    @State private var showSheet: Bool = false
    
    @State private var showAlert: Bool = false
    
    private let timerHours: [Int] = [1, 2, 3, 6]
    
    private var sleepModeIcon: String {
        return deviceState.isSleepModeOn ? "moon.fill" : "moon"
    }
    
    private var ledIcon: String {
        return deviceState.isLedOn ? "lightbulb.fill" : "lightbulb"
    }
    
    private var ledText: String {
        return deviceState.isLedOn ? "Light On" : "Light Off"
    }
    
    private var sleepModeText: String {
        return deviceState.isSleepModeOn ? "Sleep On" : "Sleep Off"
    }
    
    private var timerText: String {
        if let timerText = deviceState.timerDisplayString {
            return timerText
        }
        return "Timer Off"
    }
    
    private var timerIcon: String {
        return deviceState.isTimerOn ? "clock.fill" : "clock"
    }
    
    private var playPauseIcon: String {
        return deviceState.isTimerOn ? "stop.fill" : "play.fill"
    }
    
    private var playPauseText: String {
        return deviceState.isTimerOn ? "Stop Timer" : "Start Timer"
    }
    
    var body: some View {
        VStack {
            Button {
                deviceState.isSleepModeOn.toggle()
                sendUpdateCommand(with: .isSleepModeOn)
            } label: {
                Text("\(Image(systemName: sleepModeIcon)) \(sleepModeText)")
            }
            
            lightModeControlView
            
            timerControlView
        }
        .onChange(of: UDPListener.shared.deviceStateData) { oldState, newState in
            guard let newState else { return }
            updateDeviceState(state: newState)
        }
        .onChange(of: device.state) { _, _ in
            updateDeviceState()
        }
        .onChange(of: deviceState.speed) { _, _ in
            if isUserInteracting {
                handleSliderInput(with: .speed)
            }
        }
        .onChange(of: deviceState.brightness) { _, _ in
            if isUserInteracting {
                handleSliderInput(with: .brightness)
            }
        }
        .onChange(of: selectedColorMode) { _, newColorMode in
            deviceState.color = newColorMode.rawValue
            handleSliderInput(with: .lightMode)
        }
        .onAppear {
            updateDeviceState()
        }
        .alert(viewModel.errorMessage, isPresented: $showAlert) {
            Button("OK") {
                viewModel.errorMessage = "" //resetting error
            }
        }
        .onChange(of: viewModel.errorMessage) { oldMessage, newMessage in
            if !newMessage.isEmpty {
                showAlert.toggle()
            }
        }
    }
    
    private var lightButton: some View {
        Button {
            deviceState.isLedOn.toggle()
            sendUpdateCommand(with: .isLedOn)
        } label: {
            Text("\(Image(systemName: ledIcon)) \(ledText)")
        }
    }
    
    @ViewBuilder
    private var lightModeControlView: some View {
        if device.model.lowercased().contains("aris") {
            Button {
                showSheet.toggle()
            } label: {
                Text("\(Image(systemName: ledIcon)) \(ledText)")
            }
            .sheet(isPresented: $showSheet) {
                VStack {
                    lightButton
                    
                    Slider(value: $deviceState.brightness, in: 10.0...100, step: 10.0) {
                        Text("Brightness")
                    } minimumValueLabel: {
                        Image(systemName: "light.min")
                    } maximumValueLabel: {
                        Image(systemName: "light.max")
                    } onEditingChanged: { isEditing in
                        isUserInteracting = isEditing
                    }
                    .tint(.primary)
                    
                    Picker("Light Mode", selection: $selectedColorMode) {
                        ForEach(ColorMode.allCases, id: \.self) { option in
                            Text(option.displayText)
                        }
                    }
                    .labelsHidden()
                }
                .presentationCompactAdaptation(.sheet)
            }
        } else {
            lightButton
        }
    }
    
    private var timerControlView: some View {
        Button {
            showTimer.toggle()
        } label: {
            Text("\(Image(systemName: timerIcon)) \(timerText)")
        }
        .sheet(isPresented: $showTimer) {
            VStack {
                if let displayTimer = deviceState.timerDisplayString {
                    Text(displayTimer)
                } else {
                    Picker(selection: $selectedTimer) {
                        ForEach(timerHours, id: \.self) { timer in
                            Text("\(timer)")
                        }
                    } label: {
                        Text("Timer")
                    }
                    .pickerStyle(.automatic)
                }
                
                Button {
                    if deviceState.isTimerOn {
                        deviceState.timerHour = 0
                        sendUpdateCommand(with: .timer)
                    } else {
                        deviceState.timerHour = selectedTimer
                        sendUpdateCommand(with: .timer)
                    }
                } label: {
                    Text("\(Image(systemName: playPauseIcon)) \(playPauseText)")
                }
            }
            .presentationCompactAdaptation(.sheet)
        }
    }
    
    private func updateDeviceState() {
        guard let state = device.state else { return }
        var isCool = false
        var isWarm = false
        if let lastRecordedColor = state.lastRecordedColor {
            switch ColorMode(rawValue: lastRecordedColor.lowercased()) {
                case .cool:
                    isCool = true
                case .warm:
                    isWarm = true
                case .daylight:
                    isCool = true
                    isWarm = true
                case .none:
                    break
            }
        }
        deviceState = FanState(deviceID: state.deviceID,
                               isOnline: state.isOnline,
                               isPoweredOn: state.isPoweredOn,
                               isLedOn: state.isLedOn,
                               isSleepModeOn: state.isSleepModeOn,
                               speed: Double(state.lastRecordedSpeed),
                               timerHour: state.timerHours,
                               timerMins: state.timeElapsedInMins,
                               brightness: Double(state.lastRecordedBrightness ?? .zero),
                               cool: isCool,
                               warm: isWarm)
        selectedColorMode = deviceState.colorMode ?? .daylight
    }
    
    private func updateDeviceState(state: FanState) {
        self.deviceState = state
    }
    
    private func handleSliderInput(with controlType: DeviceControlType) {
        sliderWorkItem?.cancel()
        
        let workItem = DispatchWorkItem {
            sendUpdateCommand(with: controlType)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)
        
        sliderWorkItem = workItem
    }
    
    private func sendUpdateCommand(with controlType: DeviceControlType) {
        Task {
            await viewModel.controlDevice(with: controlType, and: deviceState)
        }
    }
}

#Preview {
    let mockDevice2: Device = Device(metadata: Metadata(ssid: "wifiname"),
                                     deviceID: "a0764ee4210c",
                                     color: "Pearl White",
                                     series: "R1",
                                     model: "aris",
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
    WatchDeviceDetailsView(viewModel: WatchControlVM(), device: .constant(mockDevice2))
}
