//
//  URIComponents.swift
//  AtomicControl
//
//  Created by Sujit Thorat on 04/09/24.
//

import Foundation

enum Scheme: String {
    case https = "https"
}

enum Host: String {
    case atombergDev = "api.developer.atomberg-iot.com"
    case atombergProd = "server.atomberg-iot.com"
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}
