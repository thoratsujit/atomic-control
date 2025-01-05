//
//  NetworkService.swift
//  AtomicControl
//
//  Created by Sujit Thorat on 04/09/24.
//

import Foundation
import SwiftUI

protocol NetworkServiceProvider {
    associatedtype URNType: URI
    
    func execute<URNType: URI>(with urnType: URNType) async throws -> URNType.Derived
}

struct NetworkService {
    
    static let shared = NetworkService()
    
    private let session: URLSession
    
    private init() {
        // Configure the session
        let configuration = URLSessionConfiguration.default
        configuration.waitsForConnectivity = true
        configuration.timeoutIntervalForRequest = 30 // Set a timeout of 30 seconds
        self.session = URLSession(configuration: configuration)
    }
    
    func execute<URNType>(with urnType: URNType) async throws -> URNType.Derived where URNType : URI {
        guard let request = urnType.getURLRequest() else {
            throw NetworkError.failedRequestGen
        }
        do {
            let (data, response) = try await session.data(for: request)
            try validateResponse(for: response, data: data)
            return try decodeResponse(for: urnType, from: data)
        } catch let error as URLError {
            if error.code == .timedOut {
                throw NetworkError.timeout
            }
            throw NetworkError.unknown(error)
        }
    }
    
    private func decodeResponse<URNType>(for urnType: URNType, from data: Data) throws -> URNType.Derived where URNType : URI {
        let decoder = JSONDecoder()
        return try decoder.decode(URNType.Derived.self, from: data)
    }
}

private extension NetworkService {
    func validateResponse(for response: URLResponse, data: Data) throws {
        guard let response = response as? HTTPURLResponse else {
            throw NetworkError.notfound
        }
        switch response.statusCode {
            case StatusCode.success.rawValue:
                break
            case StatusCode.unauthorized.rawValue:
                throw NetworkError.unauthorized
            case StatusCode.forbidden.rawValue:
                throw NetworkError.forbidden
            case StatusCode.notFound.rawValue:
                throw NetworkError.notfound
            case StatusCode.apiLimitReached.rawValue:
                throw NetworkError.apiLimitReached
            case 202...500:
                throw NetworkError.dataParsingError
            default:
                throw NetworkError.failedAPI
        }
    }
}


// MARK: Load Mock data from json file
func load<T: Decodable>(_ filename: String) -> T {
    let data: Data
    
    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
    else {
        fatalError("Couldn't find \(filename) in main bundle.")
    }
    
    
    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }
    
    
    do {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
    }
}
