//
//  Coordinator.swift
//  AtomicControl
//
//  Created by Sujit Thorat on 05/09/24.
//

import Foundation
import SwiftUI

class Coordinator: ObservableObject {
    
    @Published var path: NavigationPath = NavigationPath()
    @Published var toastManager = ToastManager()
    @Published var sheet: Sheet?
    @Published var fullScreenCover: FullScreenCover?
    
    @AppStorage("atomicHomeAppTheme") var theme: Theme = .system
    
    private let linearGradient = LinearGradient(colors: [.topg, .bottomg, .blue],
                                                    startPoint: .bottomLeading,
                                                    endPoint: .topTrailing)
    
    func push(page: AppScreens) {
        path.append(page)
    }
    
    func pop() {
        path.removeLast()
    }
    
    func popToRoot() {
        path.removeLast(path.count)
    }
    
    func presentSheet(_ sheet: Sheet) {
        self.sheet = sheet
    }
    
    func presentFullScreenCover(_ cover: FullScreenCover) {
        self.fullScreenCover = cover
    }
    
    func dismissSheet() {
        self.sheet = nil
    }
    
    func dismissCover() {
        self.fullScreenCover = nil
    }
    
    /// Auto Dismissing Toast
    func showNotificationToast(message: String) {
        toastManager.showNotificationToast(message: message)
    }
    
    func showActionToast(message: String, action: (() -> Void)? = nil, dismissAction: (() -> Void)? = nil) {
        toastManager.showActionToast(message: message, action: action, dismissAction: dismissAction)
    }
}

extension Coordinator {
    
    func build(page: AppScreens) -> some View {
        VStack {
            switch page {
                case .onboarding:
                    OnboardingView()
                case .home:
                    HomeView()
                case .details(let viewModel, let device):
                    DeviceDetailsView(viewModel: viewModel, device: device)
            }
        }
        .preferredColorScheme(theme.colorSheme)
        .background {
            linearGradient
                .ignoresSafeArea()
        }
    }
    
    @ViewBuilder
    func buildSheet(sheet: Sheet) -> some View {
        ZStack {
            linearGradient
                .ignoresSafeArea()
            switch sheet {
                case .settings:
                    SettingsView()
            }
        }
        .showToastOverlay(toastManager: toastManager)
        .preferredColorScheme(theme.colorSheme)
    }
    
    func buildCover(cover: FullScreenCover) -> some View {
        ZStack {
            linearGradient
                .ignoresSafeArea()
            switch cover {
                case .signup:
                    SomeView()
            }
        }
        .showToastOverlay(toastManager: toastManager)
        .preferredColorScheme(theme.colorSheme)
    }
}

enum AppScreens: Hashable, Equatable, Identifiable {
    case onboarding
    case home
    case details(DeviceViewModel, Binding<Device>)
    
    var id: String {
        switch self {
            case .onboarding:
                return "fbx-onboarding"
            case .home:
                return "fbx-home"
            case .details(_, let device):
                return "fbx-details-\(device.wrappedValue.deviceID)"
        }
    }
}

extension AppScreens {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: AppScreens, rhs: AppScreens) -> Bool {
        return lhs.id == rhs.id
    }
}

enum Sheet: String, Identifiable {
    var id: String {
        self.rawValue
    }
    
    case settings
}

enum FullScreenCover: String, Identifiable {
    var id: String {
        self.rawValue
    }
    
    case signup
}

struct SomeView: View {
    
    @EnvironmentObject var coordinator: Coordinator
    
    var body: some View {
        VStack {
            Text("Hello World!")
            IconicButton(icon: "arrow.backward") {
                coordinator.dismissCover()
            }
            IconicButton(icon: "exclamationmark.square") {
                coordinator.showNotificationToast(message: "Notification message")
            }
        }
    }
}
