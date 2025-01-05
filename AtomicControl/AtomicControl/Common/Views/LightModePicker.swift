//
//  LightModePicker.swift
//  AtomicControl
//
//  Created by Sujit Thorat on 04/10/24.
//

import SwiftUI

struct LightModePicker: View {
    @Namespace private var slideAnimation
    @Binding var selectedOption: ColorMode
    let onEditingChanged: (Bool) -> Void
    
    var body: some View {
        HStack {
            ForEach(ColorMode.allCases, id: \.self) { option in
                VStack {
                    option.color
                        .frame(width: 24, height: 24)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                    Text(option.displayText)
                }
                .frame(maxWidth: .infinity)
                .padding(8)
                .background {
                    ZStack {
                        if selectedOption == option {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(.gray.opacity(0.25))
                                .matchedGeometryEffect(id: "slideAnimation", in: slideAnimation)
                        }
                    }
                    .animation(.snappy, value: selectedOption)
                }
                .onTapGesture {
                    onEditingChanged(true)
                    selectedOption = option
                }
            }
        }
        .padding(2)
        .onChange(of: selectedOption, perform: { newValue in
            hapticFeedback(.selection)
            onEditingChanged(false)
        })
    }
}

