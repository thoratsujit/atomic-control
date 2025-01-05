//
//  IconicButton.swift
//  AtomicControl
//
//  Created by Sujit Thorat on 08/09/24.
//

import SwiftUI

struct IconicButton: View {
    let icon: String
    var tintColor: Color?
    var showShadow: Bool?
    var size: CGSize = Constant.imageSize
    var imagePadding: CGFloat = Constant.imagePadding
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            hapticFeedback(.impact(.medium))
            action()
        }) {
            iconicImage
                .frame(width: size.width, height: size.height)
                .background(.ternaryBackground,
                            in: RoundedRectangle(cornerRadius: Constant.cornerRadius))
                .dropShadow(shouldShowShadow: showShadow ?? false)
        }
    }
    
    private var iconicImage: some View {
        Image(systemName: icon)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .padding(imagePadding)
            .foregroundStyle(tintColor ?? .primary)
    }
    
    private enum Constant {
        static let cornerRadius: CGFloat = 8
        static let imagePadding: CGFloat = 8
        
        static let imageSize: CGSize = CGSize(width: 40, height: 40)
    }
}

#Preview {
    IconicButton(icon: "power",
                 showShadow: true) {
        print("POWER")
    }
}
