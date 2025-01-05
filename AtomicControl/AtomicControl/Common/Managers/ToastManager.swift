//
//  ToastManager.swift
//  AtomicControl
//
//  Created by Sujit Thorat on 16/09/24.
//

import Foundation

struct ToastMessage: Identifiable, Equatable {
    let id = UUID()
    var message: String
    var action: (() -> Void)?
    var dismissAction: (() -> Void)?
    
    static func == (lhs: ToastMessage, rhs: ToastMessage) -> Bool {
        return lhs.id == rhs.id
    }
}

class ToastManager: ObservableObject {
    @Published var currentToast: ToastMessage?
    
    private let seconds: TimeInterval = 3
    private var toastQueue: [ToastMessage] = []
    
    func showNotificationToast(message: String) {
        let toastMessage = ToastMessage(message: message)
        enqueueToast(toastMessage)
    }
    
    func showActionToast(message: String, action: (() -> Void)? = nil, dismissAction: (() -> Void)? = nil) {
        let toastMessage = ToastMessage(message: message, action: action, dismissAction: dismissAction)
        enqueueToast(toastMessage)
    }
    
    func dismissToast() {
        currentToast = nil
        if !toastQueue.isEmpty {
            toastQueue.removeFirst() // Remove the currently shown toast
            showNextToast() // Show the next toast in the queue, if any
        }
    }
    
    private func enqueueToast(_ toastMessage: ToastMessage) {
        toastQueue.append(toastMessage)
        showNextToast()
    }
    
    private func showNextToast() {
        // If there's already a toast being shown, do nothing
        guard currentToast == nil else { return }
        
        // Show the next toast in the queue
        if let nextToast = toastQueue.first {
            currentToast = nextToast
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                self.dismissToast()
            }
        }
    }
}
