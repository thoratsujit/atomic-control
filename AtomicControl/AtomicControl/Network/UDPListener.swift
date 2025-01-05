//
//  UDPListener.swift
//  AtomicControl
//
//  Created by Sujit Thorat on 04/09/24.
//

import Foundation
import Network

final class UDPListener: ObservableObject {
    
    static let shared = UDPListener()
    
    @Published private var deviceStateString: String = "Waiting for data..."
    @Published var deviceStateData: FanState?
    
    private var listener: NWListener?
    private let port: NWEndpoint.Port = 5625
    private let queue = DispatchQueue(label: "com.fabex3d.atomiccontrol.udp", qos: .userInitiated)
    
    private init() {}
    
    func startListening() {
        guard listener == nil else {
            print("Listener is already running on port \(port)")
            return
        }
        
        let parameters = NWParameters.udp
        parameters.allowFastOpen = true
        
        do {
            listener = try NWListener(using: parameters, on: port)
            
            listener?.newConnectionHandler = { [weak self] connection in
                self?.setupNewConnection(connection)
            }
            
            listener?.stateUpdateHandler = { [weak self] state in
                self?.handleListenerStateChange(state)
            }
            
            listener?.start(queue: queue)
        } catch {
            print("Failed to start listener: \(error)")
        }
    }
    
    private func handleListenerStateChange(_ state: NWListener.State) {
        switch state {
            case .setup:
                print("State: setup")
            case .waiting(let error):
                print("State: waiting - \(error)")
                restartListener()  // Handle waiting state by restarting
            case .ready:
                print("State: ready")
            case .failed(let error):
                print("State: failed - \(error)")
                stopListening()
            case .cancelled:
                print("State: cancelled")
            @unknown default:
                print("State: unknown")
        }
    }
    
    private func setupNewConnection(_ connection: NWConnection) {
        connection.stateUpdateHandler = { [weak self] state in
            self?.handleConnectionStateChange(state, connection: connection)
        }
        handle(connection: connection)
    }
    
    private func handleConnectionStateChange(_ state: NWConnection.State, connection: NWConnection) {
        switch state {
            case .setup:
                print("NWConnection State: setup")
            case .waiting(let error):
                print("NWConnection State: waiting - \(error)")
                // Retry the connection
                connection.cancel()
                restartListener()
            case .preparing:
                print("NWConnection State: preparing")
            case .ready:
                print("NWConnection State: ready")
            case .failed(let error):
                print("NWConnection State: failed - \(error)")
                connection.cancel()  // Ensure cancellation on failure
                restartListener()
            case .cancelled:
                print("NWConnection State: cancelled")
            @unknown default:
                print("NWConnection State: unknown")
        }
    }
    
    private func handle(connection: NWConnection) {
        connection.start(queue: queue)
        receive(on: connection)
    }
    
    private func receive(on connection: NWConnection) {
        connection.receiveMessage { [weak self] data, _, isComplete, error in
            guard let self else { return }
            if let data = data, !data.isEmpty {
                guard let message = String(data: data, encoding: .utf8) else {
                    // Handle decoding error
                    print("Decoding Error String")
                    return
                }
                
                if let deviceState = message.hexToASCII {
                    DispatchQueue.main.async {
                        self.deviceStateString = deviceState
                        self.deviceStateData = self.getDeviceStateData(stateString: deviceState)
                        print("ReceivedDeviceStateData: ", deviceState, "\n", self.deviceStateData as Any)
                    }
                }
            }
            if isComplete {
                connection.cancel()  // Cancel the connection when done
            } else if let error = error {
                print("Error receiving data: \(error)")
                self.receive(on: connection)  // Retry receiving
            } else {
                self.receive(on: connection)
            }
        }
    }
    
    private func stopListening() {
        listener?.cancel()
        listener = nil
        print("Stopped listening on port \(port.rawValue)")
    }
    
    private func restartListener() {
        stopListening()
        startListening()
    }
    
    private func getDeviceStateData(stateString: String) -> FanState? {
        guard let udpResponse = stateString.decode(to: DeviceStateUDP.self),
              let deviceStateData = decodeDeviceState(from: udpResponse) else {
            return nil
        }
        
        return deviceStateData
    }
}

func decodeDeviceState(from response: DeviceStateUDP) -> FanState? {
    guard let state = response.state else {
        return nil
    }
    
    let components = state.split(separator: ",")
    
    if let valueString = components.first?.trimmingCharacters(in: .whitespaces), let value = Int(valueString) {
        
        let power: Bool = (0x10 & value) > 0
        let led: Bool = (0x20 & value) > 0
        let sleep: Bool = (0x80 & value) > 0
        let speed: Double = Double(0x07 & value)
        let timerHours: Int = (0x0F0000 & value) / 65536
        #if os(iOS)
        let timerElapsedMin: Int = (0xFF000000 & value) * 4 / 16777216 // Does not support on 32bit arch(watch)
        #elseif os(watchOS)
        let timerElapsedMin: Int = .zero
        #endif
        
        // MARK: Remaining Time Calculations
        // Total minutes in the timer
        let totalMinutes = timerHours * 60
        
        // Subtract the elapsed minutes from the total time
        let remainingMinutes = totalMinutes - timerElapsedMin
        
        // Convert remaining time back to hours and minutes
        let remainingHours = remainingMinutes / 60
        let remainingMins = remainingMinutes % 60
        
        // Set brightness value if device supports brightness control
        // if device supports brightness control
//        let brightness = (0x7F00 & value) >> 8
        let brightness: Int = (0x7F00 & value) / 256
        
        // Set color mode if device supports color modes
        // if device supports color effects
        let cool = (0x08 & value) > 0
        let warm = (0x8000 & value) > 0
        
        var lightMode: String = ""
        
        if cool && warm {
            lightMode = "Daylight"
        } else if cool {
            lightMode = "Cool"
        } else if warm {
            lightMode = "Warm"
        }
        
        return FanState(
            deviceID: response.deviceID,
            isPoweredOn: power,
            isLedOn: led,
            isSleepModeOn: sleep,
            speed: speed,
            timerHour: remainingHours,
            timerMins: remainingMins,
            brightness: Double(brightness),
            cool: cool,
            warm: warm,
            color: lightMode
        )
    }
    return nil
}
