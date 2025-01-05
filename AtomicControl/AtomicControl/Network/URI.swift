//
//  URI.swift
//  AtomicControl
//
//  Created by Sujit Thorat on 04/09/24.
//

import Foundation

protocol URI {
    associatedtype Derived: Decodable
    var httpMethod: HTTPMethod { get }
    var scheme: Scheme { get }
    var headers: [String: String]? { get }
    var host: Host { get }
    var path: Path { get }
    var isParametersPercentEncoded: Bool { get }
    var urlQueryItems: [URLQueryItem]? { get }
    var body: Data? { get }
    
    func getURLRequest() -> URLRequest?
}

extension URI {
    
    var scheme: Scheme {
        return .https
    }
    
    var host: Host {
        return .atombergDev
    }
    
    var isParametersPercentEncoded: Bool {
        return false
    }
    
    var urlQueryItems: [URLQueryItem]? {
        return nil
    }
    
    var body: Data? {
        return nil
    }
    
    func getURLRequest() -> URLRequest? {
        var urlComponents = URLComponents()
        urlComponents.host = host.rawValue
        urlComponents.scheme = scheme.rawValue
        urlComponents.path = path.rawValue
        urlComponents.queryItems = urlQueryItems
        guard let url = urlComponents.url else {
            return nil
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = httpMethod.rawValue
        urlRequest.allHTTPHeaderFields = headers
        if let body {
            urlRequest.httpBody = body
            urlRequest.setValue("application/json",
                                forHTTPHeaderField: "Content-Type")
        }
        
        return urlRequest
    }
}

// MARK: Authentication URI
protocol AuthenticationURI: URI { }

extension AuthenticationURI {
    var httpMethod: HTTPMethod {
        return .get
    }
    
    var urlQueryItems: [URLQueryItem]? {
        return nil
    }
    
    var body: Data? {
        return nil
    }
    
    var headers: [String : String]? {
        return KeychainManager.shared.getHeaders(type: .authToken)
    }
}

struct RefreshTokenURI: AuthenticationURI {
    typealias Derived = AuthData
    
    var path: Path {
        return .refreshToken
    }
}

// MARK: - Authenticated Atomic URI
protocol AtomicURI: URI {}

extension AtomicURI {
    
    var httpMethod: HTTPMethod {
        return .get
    }
    
    var urlQueryItems: [URLQueryItem]? {
        return nil
    }
    
    var body: Data? {
        return nil
    }
    
    var headers: [String : String]? {
        return KeychainManager.shared.getHeaders(type: .accessToken)
    }
}

struct DeviceListURI: AtomicURI {
    
    var path: Path {
        return .devicesList
    }
    
    typealias Derived = DeviceData
}

struct DeviceStateURI: AtomicURI {
    
    var path: Path {
        return .deviceState
    }
    
    var urlQueryItems: [URLQueryItem]?
    
    typealias Derived = DeviceStateData
}

struct CommandURI: AtomicURI {
    
    var httpMethod: HTTPMethod {
        return .post
    }
    
    var path: Path {
        return .sendCommand
    }
    
    var body: Data?
    
    typealias Derived = APIResponse
}

enum CommandKey: String {
    case deviceID = "device_id"
    case command = "command"
    case power = "power" // Bool
    case speed = "speed" // Int 1...6
    case speedDelta = "speedDelta" //Int -5...5
    case sleep = "sleep" // Bool
    case timer = "timer" // Int 1,2,3,4 | send 0 to turn off timer
    case led = "led" // Bool
    case brightness = "brightness" // Int 10 to 100 % brightness
    case brightnessDelta = "brightnessDelta" // Int -90 to +90
    case lightMode = "light_mode" // String warm/cool/daylight
}

enum QueryName: String {
    case deviceID = "device_id"
}

enum QueryValue: String {
    case all = "all"
}

enum HeaderKeys: String {
    case apiKey = "x-api-key"
    case token = "Authorization"
    case appJson = "application/json"
}

struct APIResponse: Decodable {
    var status: String?
    var message: String?
    var errorType: String?
    var errorMessage: String?
}

enum DeviceControlType {
    case isPoweredOn
    case isLedOn
    case speed
    case speedDelta
    case isSleepModeOn
    case timer
    case brightness
    case lightMode
}

enum HeaderType {
    case authToken
    case accessToken
}
