//
//  IconTextButton.swift
//  AtomicControl
//
//  Created by Sujit Thorat on 04/10/24.
//

import SwiftUI

struct IconTextButton: View {
    var systemName: String
    var text: String
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            action()
        }, label: {
            HStack(spacing: 16) {
                Image(systemName: systemName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                Text(text)
                    .frame(width: deviceWidth * 0.4)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal, 32)
        })
    }
}

