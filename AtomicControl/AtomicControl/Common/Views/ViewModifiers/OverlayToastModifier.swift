//
//  OverlayToastModifier.swift
//  AtomicControl
//
//  Created by Sujit Thorat on 16/09/24.
//

import SwiftUI

#if os(iOS)
struct OverlayToastModifier: ViewModifier {
    @StateObject var toastManager: ToastManager
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top, content: {
                if let toast = toastManager.currentToast {
                    ToastView(toast: toast)
                        .environmentObject(toastManager)
                        .offset(y: 16)
                        .transition(.move(edge: .top))
                }
            })
    }
}
#endif
