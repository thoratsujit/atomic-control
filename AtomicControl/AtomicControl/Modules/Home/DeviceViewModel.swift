//
//  DeviceViewModel.swift
//  AtomicControl
//
//  Created by Sujit Thorat on 08/09/24.
//

import SwiftUI
import Combine
import WidgetKit

@MainActor
final class DeviceViewModel: ObservableObject {
    
    private let reachability = NetworkReachabilityManager()
    private var cancellables = Set<AnyCancellable>()
    
    @AppStorage(AtomicKeys.userName.value) private(set) var userName: String = ""
    @AppStorage(AtomicKeys.homeName.value) private(set) var homeName: String = ""
    @Published var devices: [Device] = [] {
        didSet {
            storeDevicesInUserDefaults()
        }
    }
    @Published var errorMessage: String = ""
    @Published var isLoading: Bool = false
    
    init() {
        loadDevicesFromUserDefaults()
//        loadMockData()
        fetchData()
        setupSubscribers()
    }
    
    // MARK: Network Fetch Device List and Device state Data
    func fetchData() {
        isLoading = true
        defer { isLoading = false }
        Task {
            do {
                async let devicesResponse = fetchDeviceList()
                async let deviceStatesResponse = fetchAllDevicesStates()
                
                let deviceList = try await devicesResponse
                let deviceStates = try await deviceStatesResponse
                
                await MainActor.run {
                    devices = updateDeviceStates(with: deviceList, and: deviceStates)
                    WidgetUpdator.reloadWidgets()
                    isLoading = false
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
    
    func fetchAllDevicesStates() async throws -> [DeviceState] {
        let queryItems = [URLQueryItem(name: QueryName.deviceID.rawValue,
                                       value: QueryValue.all.rawValue)]
        
        let response = try await NetworkService.shared.execute(with: DeviceStateURI(urlQueryItems: queryItems))
        return response.message.deviceState
    }
    
    func fetchDeviceState(by deviceID: String = QueryValue.all.rawValue) async {
        let queryItems = [URLQueryItem(name: QueryName.deviceID.rawValue, value: deviceID)]
        
        do {
            let response = try await NetworkService.shared.execute(with: DeviceStateURI(urlQueryItems: queryItems))
//            print(response.message.deviceState)
            await MainActor.run {
                devices = updateDeviceStates(with: devices, and: response.message.deviceState)
                WidgetUpdator.reloadWidgets()
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
    
    private func setupSubscribers() {
        UDPListener.shared.$deviceStateData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] deviceStateData in
                guard let self, let deviceStateData else { return }
                self.updateDeviceStatesDataUDP(with: deviceStateData)
            }
            .store(in: &cancellables)
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
    
    private func updateDeviceStatesDataUDP(with deviceStateData: FanState) {
        devices = devices.map { device in
            var updatedDevice = device
            if device.deviceID == deviceStateData.deviceID {
                let latestDeviceState = DeviceState(deviceID: deviceStateData.deviceID,
                                                    isPoweredOn: deviceStateData.isPoweredOn,
                                                    lastRecordedSpeed: Int(deviceStateData.speed),
                                                    isSleepModeOn: deviceStateData.isSleepModeOn,
                                                    isLedOn: deviceStateData.isLedOn,
                                                    isOnline: device.state?.isOnline ?? false,
                                                    timerHours: deviceStateData.timerHour,
                                                    timeElapsedInMins: deviceStateData.timerMins,
                                                    epochSeconds: deviceStateData.timerMins,
                                                    lastRecordedBrightness: Int(deviceStateData.brightness),
                                                    lastRecordedColor: deviceStateData.color)
                updatedDevice.state = latestDeviceState
            }
            return updatedDevice
        }
        WidgetUpdator.reloadWidgets()
    }
    
    // MARK: Send Command To Device
    func controlDevice(with controlType: DeviceControlType, and deviceState: FanState) async {
        guard let data = deviceCommandData(with: controlType, and: deviceState) else {
            return
        }
        
        let commandURI = CommandURI(body: data)
        do {
            let _ = try await NetworkService.shared.execute(with: commandURI)
            // TODO: Prefer local update when connected to home network
            await fetchDeviceState(by: deviceState.deviceID)
        } catch let error as NetworkError {
            handle(error: error)
        } catch {
            handle(error: NetworkError.unknown(error))
        }
    }
    
    private func deviceCommandData(with controlType: DeviceControlType, and deviceState: FanState) -> Data? {
        var commands: [String: Any] = [:]
        switch controlType {
            case .isPoweredOn:
                commands[CommandKey.power.rawValue] = deviceState.isPoweredOn
            case .isLedOn:
                commands[CommandKey.led.rawValue] = deviceState.isLedOn
            case .speed:
                commands[CommandKey.speed.rawValue] = Int(deviceState.speed)
            case .isSleepModeOn:
                commands[CommandKey.sleep.rawValue] = deviceState.isSleepModeOn
            case .timer:
                commands[CommandKey.timer.rawValue] = deviceState.timerHour
            case .brightness:
                commands[CommandKey.brightness.rawValue] = deviceState.brightness
            case .lightMode:
                commands[CommandKey.lightMode.rawValue] = deviceState.color
            case .speedDelta:
                break
        }
        
        let requestBody: [String: Any] = [
            CommandKey.deviceID.rawValue: deviceState.deviceID,
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
            Task {
                await refreshAccessToken()
            }
        }
        DispatchQueue.main.async {
            self.isLoading = false
            self.errorMessage = error.message
        }
    }
    
    private func storeDevicesInUserDefaults() {
        UserDefaultsManager.shared.save(object: devices, key: .deviceList)
        WatchConnectivityHelper.shared.sendData(object: devices, key: .deviceList)
        WidgetUpdator.reloadWidgets()
    }
    
    private func loadDevicesFromUserDefaults() {
        devices = UserDefaultsManager.shared.retrieve(key: .deviceList, as: [Device].self) ?? []
        WidgetUpdator.reloadWidgets()
    }
    
    // MARK: - Mock response
    private func loadMockData() {
        let deviceData: DeviceData = load("deviceListResponse.json")
        let deviceStats: DeviceStateData = load("deviceStateResponse.json")
        devices = updateDeviceStates(with: deviceData.message.devicesList,
                                     and: deviceStats.message.deviceState)
    }
}
