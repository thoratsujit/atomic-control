//
//  CoordinatorView.swift
//  AtomicControl
//
//  Created by Sujit Thorat on 03/09/24.
//

import SwiftUI

struct CoordinatorView: View {
    @StateObject private var coordinator = Coordinator()
    @StateObject private var reachability = NetworkReachabilityManager()
    
    @State private var page: AppScreens = {
        if UserDefaults.standard.bool(forKey: AtomicKeys.isUserOnboarded.value) {
            return .home
        } else {
            return .onboarding
        }
    }()
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            coordinator.build(page: page)
                .navigationDestination(for: AppScreens.self) { page in
                    coordinator.build(page: page)
                }
                .sheet(item: $coordinator.sheet) { sheet in
                    coordinator.buildSheet(sheet: sheet)
                }
                .fullScreenCover(item: $coordinator.fullScreenCover) { item in
                    coordinator.buildCover(cover: item)
                }
        }
        .showToastOverlay(toastManager: coordinator.toastManager)
        .environmentObject(coordinator)
        .environmentObject(coordinator.toastManager)
        .overlay(alignment: .bottom) {
            if !reachability.isConnected {
                Text("\(Image(systemName: "network.slash")) No internet connection")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.red)
                    .foregroundStyle(.white)
            }
        }
    }
}

#Preview {
    CoordinatorView()
}
