//
//  OnFirstAppearModifier.swift
//  AtomicControl
//
//  Created by Sujit Thorat on 16/09/24.
//

import SwiftUI

struct OnFirstAppearModifier: ViewModifier {
    let perform: () -> Void
    
    @State private var firstTime = true
    
    func body(content: Content) -> some View {
        content.onAppear {
            if firstTime {
                firstTime = false
                perform()
            }
        }
    }
}
