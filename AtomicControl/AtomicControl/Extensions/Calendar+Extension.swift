//
//  Calendar+Extension.swift
//  AtomicControl
//
//  Created by Sujit Thorat on 16/09/24.
//

import Foundation

extension Calendar {
    func minutesLeft(until epochTime: TimeInterval) -> Int? {
        let currentDate = Date()
        let futureDate = Date(timeIntervalSince1970: epochTime)
        
        // Ensure that the future date is ahead of the current date
        guard futureDate > currentDate else {
            return nil // Return nil if the future date has passed
        }
        
        // Calculate the difference in components (hours and minutes)
        let components = dateComponents([.hour, .minute], from: currentDate, to: futureDate)
        
        // Safely unwrap and return hours and minutes
        if let minutes = components.minute {
            return minutes
        }
        return nil
    }
}
