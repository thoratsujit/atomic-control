//
//  HapticManager.swift
//  AtomicControl
//
//  Created by Sujit Thorat on 08/09/24.
//

import UIKit

enum HapticFeedbackType {
    case selection
    case impact(UIImpactFeedbackGenerator.FeedbackStyle)
    case notification(UINotificationFeedbackGenerator.FeedbackType)
}

final class HapticManager {
    
    private let selectionFeedback = UISelectionFeedbackGenerator()
    private let notificationFeedback = UINotificationFeedbackGenerator()
    
    static let shared = HapticManager()
    
    private init() { }
    
    
    func generateHapticFeedback(for feebackType: HapticFeedbackType) {
        switch feebackType {
            case .selection:
                selectionFeedback.selectionChanged()
            case .impact(let feedbackStyle):
                let feedbackGenerator = UIImpactFeedbackGenerator(style: feedbackStyle)
                feedbackGenerator.impactOccurred()
            case .notification(let feedbackType):
                notificationFeedback.notificationOccurred(feedbackType)
        }
    }
}

func hapticFeedback(_ type: HapticFeedbackType) {
    HapticManager.shared.generateHapticFeedback(for: type)
}
