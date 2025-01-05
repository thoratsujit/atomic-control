//
//  ToastView.swift
//  AtomicControl
//
//  Created by Sujit Thorat on 16/09/24.
//

import SwiftUI

#if os(iOS)
struct ToastView: View {
    @EnvironmentObject var toastManager: ToastManager
    let toast: ToastMessage
    
    var body: some View {
        HStack {
            Spacer()
            Text(toast.message)
                .font(.subheadline)
            if let action = toast.action {
                Button(action: {
                    action()
                }, label: {
                    Text(Image(systemName: "goforward"))
                        .font(.subheadline)
                        .padding(4)
                        .background(.ternaryBackground, in: RoundedRectangle(cornerRadius: 4))
                        .tint(.primary)
                })
            }
            if let dismiss = toast.dismissAction {
                Button(action: {
                    dismiss()
                }, label: {
                    Text(Image(systemName: "xmark"))
                        .font(.subheadline)
                        .padding(4)
                        .background(.ternaryBackground, in: RoundedRectangle(cornerRadius: 4))
                        .tint(.primary)
                })
            }
            Spacer()
        }
        .frame(minHeight: 48)
        .padding(16)
        .background(.ultraThickMaterial,
                    in: RoundedRectangle(cornerRadius: 8))
        .dropShadow(radius: 0.025)
        .padding(.horizontal, 16)
        .onTapGesture {
            toastManager.dismissToast()
        }
    }
}
#endif

#Preview {
    VStack {
        ToastView(toast: ToastMessage(message: NetworkError.forbidden.message))
        .environmentObject(ToastManager())
        ToastView(toast: ToastMessage(message: NetworkError.apiLimitReached.message,
                                     dismissAction: {
            print("dismiss action")
        }))
        ToastView(toast: ToastMessage(message: NetworkError.apiLimitReached.message,
                                      dismissAction: {
            print("dismiss action")
        }))
        ToastView(toast: ToastMessage(message: NetworkError.apiLimitReached.message,
                                      dismissAction: {
            print("dismiss action")
        }))
        .environmentObject(ToastManager())
        ToastView(toast: ToastMessage(message: "🛑 Request generation failed. Please try again.",
                                      action: {
            print("custom action")
        }, dismissAction: {
            print("dismiss action")
        }))
        .environmentObject(ToastManager())
    }
}
