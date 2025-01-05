//
//  DropShadowModifier.swift
//  AtomicControl
//
//  Created by Sujit Thorat on 16/09/24.
//

import SwiftUI

struct DropShadowModifier: ViewModifier {
    
    let shadowColor: Color
    
    var shouldShowShadow: Bool = true
    var radius: CGFloat = 8
    
    func body(content: Content) -> some View {
        if shouldShowShadow {
            content
                .shadow(color: shadowColor, radius: 8, x: .zero, y: 4.0)
        } else {
            content
        }
    }
    
}
