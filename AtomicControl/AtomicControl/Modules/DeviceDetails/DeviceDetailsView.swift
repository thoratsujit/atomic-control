//
//  DeviceDetailsView.swift
//  AtomicControl
//
//  Created by Sujit Thorat on 05/09/24.
//

import SwiftUI

struct DeviceDetailsView: View {
    
    @EnvironmentObject private var coordinator: Coordinator
    @ObservedObject var viewModel: DeviceViewModel
    
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
    
    @Binding var device: Device
    @State private var sliderWorkItem: DispatchWorkItem?
    @State private var isUserInteracting: Bool = false
    
    @State private var selectedLightMode: ColorMode = .daylight
    @State private var selectedTimer: Int = 1

    @State private var showTimer: Bool = false
    @State private var showSheet: Bool = false
    
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
            headerView
            controlView
            Spacer(minLength: .zero)
        }
        .navigationBarBackButtonHidden()
        .onChange(of: viewModel.errorMessage) { message in
            if !message.isEmpty {
                coordinator.showNotificationToast(message: message)
                viewModel.errorMessage = "" //resetting error
            }
        }
        .onChange(of: UDPListener.shared.deviceStateData) { state in
            guard let state else { return }
            updateDeviceState(state: state)
        }
        .onChange(of: device.state) { _ in
            updateDeviceState()
        }
        .onChange(of: deviceState.speed) { _ in
            if isUserInteracting {
                handleSliderInput(with: .speed)
            }
        }
        .onChange(of: deviceState.brightness) { _ in
            if isUserInteracting {
                handleSliderInput(with: .brightness)
            }
        }
        .onChange(of: selectedLightMode) { _ in
            if isUserInteracting {
                handleSliderInput(with: .lightMode)
            }
        }
        .onAppear {
            updateDeviceState()
        }
    }
    
    private var headerView: some View {
        HStack(alignment: .center) {
            IconicButton(icon: "arrow.backward") {
                // To settings or profile or switch home
                coordinator.pop()
            }
            Spacer()
            VStack(alignment: .center) {
                Text(device.name)
                    .font(.headline)
                Text(device.room)
                    .font(.subheadline)
            }
            Spacer()
            IconicButton(icon: "ellipsis") {
                // To settings or profile or switch home
                viewModel.errorMessage = "Coming Soon"
            }
            .rotationEffect(.degrees(90))
        }
        .padding(16)
        .background(.bar)
    }
    
    private var controlView: some View {
        ScrollView {
            fanControllerView
            
            IconTextButton(systemName: sleepModeIcon, text: sleepModeText) {
                deviceState.isSleepModeOn.toggle()
                sendUpdateCommand(with: .isSleepModeOn)
            }
            
            lightModeControlView
            
            timerControlView
        }
        .foregroundStyle(.primary)
    }
    
    private var fanControllerView: some View {
        FanControllerView(
            speed: $deviceState.speed,
            isPoweredOn: $deviceState.isPoweredOn,
            config: .init(minimumValue: 0.1, maximumValue: 6.0,
                          totalValue: 5.9,
                          knobRadius: 16,
                          radius: deviceWidth * 0.29),
            buttonTapped: {
                sendUpdateCommand(with: .isPoweredOn)
            },
            onEditingChanged: { isEditing in
                isUserInteracting = isEditing
            }
        )
        .clipShape(Circle())
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
    }
    
    private var lightButton: some View {
        IconTextButton(systemName: ledIcon, text: ledText) {
            deviceState.isLedOn.toggle()
            sendUpdateCommand(with: .isLedOn)
        }
    }
    
    @ViewBuilder
    private var lightModeControlView: some View {
        if device.model.lowercased().contains("aris") {
            IconTextButton(systemName: ledIcon, text: ledText) {
                showSheet.toggle()
            }
            .sheet(isPresented: $showSheet) {
                VStack {
                    lightButton
                    Slider(value: $deviceState.brightness, in: 10.0...100, step: 1.0) {
                        Text("Brightness")
                    } minimumValueLabel: {
                        Image(systemName: "light.min")
                    } maximumValueLabel: {
                        Image(systemName: "light.max")
                    } onEditingChanged: { isEditing in
                        isUserInteracting = isEditing
                    }
                    .tint(.primary)
                    .padding()
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
                    .padding(.horizontal, 32)
                    
                    LightModePicker(selectedOption: $selectedLightMode,
                                    onEditingChanged: { isEditing in
                        isUserInteracting = true
                        deviceState.color = selectedLightMode.rawValue
                    })
                    .padding(4)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
                    .padding(.horizontal, 32)
                }
                .presentationDetents([.fraction(0.45), .fraction(0.75)])
                .presentationBackground(.ultraThinMaterial)
                .presentationCompactAdaptation(.sheet)
            }
        } else {
            lightButton
        }
    }
    
    private var timerControlView: some View {
        IconTextButton(systemName: timerIcon, text: timerText) {
            showTimer.toggle()
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
                    .pickerStyle(.wheel)
                    .padding(.horizontal, 32)
                }
                
                IconTextButton(systemName: playPauseIcon, text: playPauseText) {
                    if deviceState.isTimerOn {
                        deviceState.timerHour = 0
                        sendUpdateCommand(with: .timer)
                    } else {
                        deviceState.timerHour = selectedTimer
                        sendUpdateCommand(with: .timer)
                    }
                }
            }
            .presentationDetents([.fraction(0.45), .fraction(0.75)])
            .presentationBackground(.ultraThinMaterial)
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
        selectedLightMode = deviceState.colorMode ?? .daylight
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
    DeviceDetailsView(viewModel: DeviceViewModel(),
                      device: .constant(mockDevice2))
    .background {
        Image(.valley)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .ignoresSafeArea()
    }
}
