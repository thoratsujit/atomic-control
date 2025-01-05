//
//  ThemePicker.swift
//  AtomicControl
//
//  Created by Sujit Thorat on 04/10/24.
//

import SwiftUI

enum Theme: String, CaseIterable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
    
    var icon: Image {
        switch self {
            case .system:
                return Image(systemName: "square.lefthalf.filled")
            case .light:
                return Image(systemName: "square.fill")
            case .dark:
                return Image(systemName: "square.fill")
        }
    }
    
    var iconStyle: Color {
        switch self {
            case .light:
                return .white
            case .dark, .system:
                return .black
        }
    }
    
    var colorSheme: ColorScheme? {
        switch self {
            case .system:
                return nil
            case .light:
                return .light
            case .dark:
                return .dark
        }
    }
}

struct ThemePicker: View {
    @Namespace private var slideAnimation
    
    @Binding var selectedOption: Theme
    
    var body: some View {
        HStack(spacing: .zero) {
            ForEach(Theme.allCases, id: \.self) { option in
                HStack(spacing: 4) {
                        Text("\(option.icon)")
                            .font(.title3).fontWeight(.regular)
                            .foregroundStyle(option.iconStyle)
                        Text(option.rawValue)
                            .font(.title3).fontWeight(.regular)
                }
                .frame(maxWidth: .infinity)
                .padding(4)
                .background {
                    ZStack {
                        if selectedOption == option {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(.regularMaterial)
                                .matchedGeometryEffect(id: "slideAnimation", in: slideAnimation)
                        }
                    }
                    .animation(.snappy, value: selectedOption)
                }
                .onTapGesture {
                    selectedOption = option
                }
            }
        }
        .padding(2)
        .background(.gray.opacity(0.5), in: .rect(cornerRadius: 4.0))
        .onChange(of: selectedOption, perform: { newValue in
            hapticFeedback(.selection)
        })
    }
}

#Preview {
    ThemePicker(selectedOption: .constant(.system))
}
