//
//  View+Extension.swift
//  AtomicControl
//
//  Created by Sujit Thorat on 04/09/24.
//

import SwiftUI

// MARK: View Extension Properties
extension View {
#if os(iOS)
    var deviceWidth: CGFloat {
        let window = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .map({$0 as? UIWindowScene})
            .compactMap({$0})
            .first?.windows
            .filter({$0.isKeyWindow}).first
        return window?.frame.width ?? .zero
    }
#endif
}

// MARK: View Extension Methods
extension View {
    func onFirstAppear(perform: @escaping () -> Void) -> some View {
        modifier(OnFirstAppearModifier(perform: perform))
    }
    
    func dropShadow(shadowColor: Color = .black.opacity(0.3),
                    shouldShowShadow: Bool = true,
                    radius: CGFloat = 8) -> some View {
        modifier(DropShadowModifier(shadowColor: shadowColor,
                                    shouldShowShadow: shouldShowShadow,
                                    radius: radius))
    }
    
    func viewBackground(_ background: BackgroundStyle) -> some View {
        modifier(BackgroundViewModifier(background: background))
    }
    
#if os(iOS)
    func showToastOverlay(toastManager: ToastManager) -> some View {
        modifier(OverlayToastModifier(toastManager: toastManager))
    }
#endif
    
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// TODO: Move to separate files
enum BackgroundStyle {
    case color(Color)
    case gradient(Gradient)
    case linearGradient(LinearGradient)
    case angularGradient(AngularGradient)
    case radialGradient(RadialGradient)
    case image(Image)
}

struct BackgroundViewModifier: ViewModifier {
    
    let background: BackgroundStyle
    
    func body(content: Content) -> some View {
        ZStack {
            backgroundView
                .ignoresSafeArea()
            content
        }
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        switch background {
            case .color(let color):
                color
            case .gradient(let gradient):
                Rectangle()
                    .fill(gradient)
            case .linearGradient(let gradient):
                Rectangle()
                    .fill(gradient)
            case .angularGradient(let gradient):
                Rectangle()
                    .fill(gradient)
            case .radialGradient(let gradient):
                Rectangle()
                    .fill(gradient)
            case .image(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(minWidth: .zero, maxWidth: .infinity, minHeight: .zero, maxHeight: .infinity)
        }
    }
}
