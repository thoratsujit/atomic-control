//
//  StatusCode.swift
//  AtomicControl
//
//  Created by Sujit Thorat on 04/09/24.
//

import Foundation

enum StatusCode: Int {
    case success = 200
    case unauthorized = 401
    case forbidden = 403
    case notFound = 404
    case apiLimitReached = 429
}
