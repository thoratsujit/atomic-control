//
//  FanState.swift
//  AtomicControl
//
//  Created by Sujit Thorat on 16/09/24.
//

import SwiftUI

enum ColorMode: String, CaseIterable {
    case warm = "warm"
    case daylight = "daylight"
    case cool = "cool"
    
    var color: Color {
        switch self {
            case .cool:
                return Color.cool
            case .warm:
                return Color.warm
            case .daylight:
                return Color.daylight
        }
    }
    
    var displayText: String {
        switch self {
            case .cool:
                return "Cool"
            case .warm:
                return "Warm"
            case .daylight:
                return "Daylight"
        }
    }
}

struct FanState: Decodable, Equatable {
    var deviceID: String
    var isOnline: Bool = false
    var isPoweredOn: Bool
    var isLedOn: Bool
    var isSleepModeOn: Bool
    var speed: Double
    var timerHour: Int
    var timerMins: Int
    var brightness: Double
    var cool: Bool
    var warm: Bool
    var color: String?
    
    var colorMode: ColorMode? {
        if cool && warm {
            return .daylight
        } else if cool {
            return .cool
        } else if warm {
            return .warm
        }
        return nil
    }
    
    var timerDisplayString: String? {
        if timerMins != .zero || timerHour != .zero {
            return "\(timerHour.leadingZeroString()):\(timerMins.leadingZeroString())"
        }
        return nil
    }
    
    var isTimerOn: Bool {
        if timerMins != .zero || timerHour != .zero {
            return true
        }
        return false
    }
}
