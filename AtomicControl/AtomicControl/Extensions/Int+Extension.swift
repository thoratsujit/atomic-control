//
//  Int+Extension.swift
//  AtomicControl
//
//  Created by Sujit Thorat on 16/09/24.
//

import Foundation

extension Int {
    // Function to format the integer with a leading zero if it's a single digit
    func leadingZeroString() -> String {
        return String(format: "%02d", self)
    }
}
