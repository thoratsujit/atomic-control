//
//  WidgetVM.swift
//  AtomicControl
//
//  Created by Sujit Thorat on 19/09/24.
//

import Foundation
import Combine
import WidgetKit

final class WidgetVM: ObservableObject {
    
    static let shared: WidgetVM = WidgetVM()
    
    var devices: [Device] = [] {
        didSet {
            storeDevicesInUserDefaults()
        }
    }
    
    @Published var errorMessage: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        loadDevicesFromUserDefaults()
        setupSubscribers()
    }
    
    private func setupSubscribers() {
        UDPListener.shared.$deviceStateData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                WidgetUpdator.reloadWidgets()
            }
            .store(in: &cancellables)
        
        WatchConnectivityHelper.shared.$refreshData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                WidgetUpdator.reloadWidgets()
            }
            .store(in: &cancellables)
    }
    
    // MARK: Fetch Device List and Device state Data
    func fetchData() {
        Task {
            do {
                async let devicesResponse = fetchDeviceList()
                async let deviceStatesResponse = fetchAllDevicesStates()
                
                let deviceList = try await devicesResponse
                let deviceStates = try await deviceStatesResponse
                
                await MainActor.run {
                    devices = updateDeviceStates(with: deviceList, and: deviceStates)
                }
            } catch let error as NetworkError {
                handle(error: error)
            } catch {
                handle(error: NetworkError.unknown(error))
            }
        }
    }
    
    func fetchDeviceList() async throws -> [Device] {
        let response = try await NetworkService.shared.execute(with: DeviceListURI())
        return response.message.devicesList
    }
    
    func fetchAllDevicesStates(by deviceID: String = QueryValue.all.rawValue) async throws -> [DeviceState] {
        let queryItems = [URLQueryItem(name: QueryName.deviceID.rawValue, value: deviceID)]
        
        let response = try await NetworkService.shared.execute(with: DeviceStateURI(urlQueryItems: queryItems))
        return response.message.deviceState
    }
    
    func fetchDeviceState(by deviceID: String = QueryValue.all.rawValue) async {
        let queryItems = [URLQueryItem(name: QueryName.deviceID.rawValue, value: deviceID)]
        
        do {
            let response = try await NetworkService.shared.execute(with: DeviceStateURI(urlQueryItems: queryItems))
            await MainActor.run {
                devices = updateDeviceStates(with: devices, and: response.message.deviceState)
            }
        } catch let error as NetworkError {
            handle(error: error)
        } catch {
            handle(error: NetworkError.unknown(error))
        }
    }
    
    private func refreshAccessToken() async {
        do {
            let response = try await NetworkService.shared.execute(with: RefreshTokenURI())
            let refreshToken = response.message.refreshToken
            try KeychainManager.shared.update(value: refreshToken, forKey: .refreshToken)
            fetchData()
        } catch let error as NetworkError {
            handle(error: error)
        } catch let error as KeychainError {
            errorMessage = error.errorDescription
        } catch {
            handle(error: NetworkError.unknown(error))
        }
    }
    
    private func updateDeviceStates(with deviceList: [Device],
                                    and newDeviceStates: [DeviceState]) -> [Device] {
        let statesDict = Dictionary(uniqueKeysWithValues: newDeviceStates.map { ($0.deviceID, $0) })
        
        return deviceList.map { device in
            var updatedDevice = device
            if let currentDeviceState = statesDict[device.deviceID] {
                updatedDevice.state = currentDeviceState
            }
            return updatedDevice
        }
    }
    
    // MARK: Widget Update Command
    private func sendCommand(for deviceID: String, with data: Data) async {
        let commandURI = CommandURI(body: data)
        do {
            let _ = try await NetworkService.shared.execute(with: commandURI)
            await fetchDeviceState(by: deviceID)
        } catch let error as NetworkError {
            handle(error: error)
        } catch {
            handle(error: NetworkError.unknown(error))
        }
    }
    
    // MARK: Widget Power Control
    func controlPower(with controlType: DeviceControlType, and deviceID: String, isPoweredOn: Bool) async {
        guard let data = deviceCommandData(with: controlType, deviceID: deviceID, and: isPoweredOn) else {
            return
        }
        await sendCommand(for: deviceID, with: data)
    }
    
    // MARK: Widget Speed Control
    func controlSpeed(with controlType: DeviceControlType, and deviceID: String, speed: Int) async {
        guard let data = deviceCommandData(with: controlType, deviceID: deviceID, and: speed) else {
            return
        }
        
        await sendCommand(for: deviceID, with: data)
    }
    
    private func deviceCommandData(with controlType: DeviceControlType, deviceID: String, and value: Any) -> Data? {
        var commands: [String: Any] = [:]
        switch controlType {
            case .isPoweredOn:
                commands[CommandKey.power.rawValue] = value
            case .isLedOn:
                commands[CommandKey.led.rawValue] = value
            case .speed:
                commands[CommandKey.speed.rawValue] = value
            case .speedDelta:
                commands[CommandKey.speedDelta.rawValue] = value
            case .isSleepModeOn:
                commands[CommandKey.sleep.rawValue] = value
            case .timer:
                break
            case .brightness:
                break
            case .lightMode:
                break
        }
        
        let requestBody: [String: Any] = [
            CommandKey.deviceID.rawValue: deviceID,
            CommandKey.command.rawValue: commands
        ]
        
        do {
            let data = try JSONSerialization.data(withJSONObject: requestBody, options: [])
            return data // Return the JSON data
        } catch {
            print("Error serializing device state to JSON: \(error)")
            return nil // Return nil if serialization fails
        }
    }
    
    // TODO: Need a look
    private func handle(error: NetworkError) {
        if case .unauthorized = error {
            print("Unauthorised Case VM")
            Task {
                await refreshAccessToken()
            }
        }
        DispatchQueue.main.async {
            self.errorMessage = error.message
        }
    }
    
    // MARK: - UserDefaults
    private func storeDevicesInUserDefaults() {
        UserDefaultsManager.shared.save(object: devices, key: .deviceList)
        //update widgets
        DispatchQueue.main.async {
            WidgetUpdator.reloadWidgets()
        }
    }
    
    func loadDevicesFromUserDefaults() {
        devices = UserDefaultsManager.shared.retrieve(key: .deviceList, as: [Device].self) ?? []
        DispatchQueue.main.async {
            WidgetUpdator.reloadWidgets()
        }
    }
    
    // MARK: - Mock response
    private func loadMockData() {
        let deviceData: DeviceData = load("deviceListResponse.json")
        let deviceStats: DeviceStateData = load("deviceStateResponse.json")
        devices = updateDeviceStates(with: deviceData.message.devicesList,
                                     and: deviceStats.message.deviceState)
    }
    
    /// UserDefaults update speed
    func updateData(deviceID: String, speed: Int) {
        devices = devices.map { device in
            var updatedDevice = device
            if device.deviceID == deviceID, let state = device.state {
                let latestDeviceState = DeviceState(deviceID: state.deviceID,
                                                    isPoweredOn: state.isPoweredOn,
                                                    lastRecordedSpeed: speed,
                                                    isSleepModeOn: state.isSleepModeOn,
                                                    isLedOn: state.isLedOn,
                                                    isOnline: state.isOnline,
                                                    timerHours: state.timerHours,
                                                    timeElapsedInMins: state.timeElapsedInMins,
                                                    epochSeconds: state.epochSeconds,
                                                    lastRecordedBrightness: state.lastRecordedBrightness,
                                                    lastRecordedColor: state.color)
                updatedDevice.state = latestDeviceState
            }
            return updatedDevice
        }
    }
    
    /// UserDefaults update power state
    func updateData(deviceID: String, power: Bool) {
        devices = devices.map { device in
            var updatedDevice = device
            if device.deviceID == deviceID, let state = device.state {
                let latestDeviceState = DeviceState(deviceID: state.deviceID,
                                                    isPoweredOn: power,
                                                    lastRecordedSpeed: state.lastRecordedSpeed,
                                                    isSleepModeOn: state.isSleepModeOn,
                                                    isLedOn: state.isLedOn,
                                                    isOnline: state.isOnline,
                                                    timerHours: state.timerHours,
                                                    timeElapsedInMins: state.timeElapsedInMins,
                                                    epochSeconds: state.epochSeconds,
                                                    lastRecordedBrightness: state.lastRecordedBrightness,
                                                    lastRecordedColor: state.color)
                updatedDevice.state = latestDeviceState
            }
            return updatedDevice
        }
    }
}
