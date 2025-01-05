//
//  WatchHomeView.swift
//  WatchControl Watch App
//
//  Created by Sujit Thorat on 15/09/24.
//

import SwiftUI

struct WatchHomeView: View {
    
    @StateObject private var viewModel: WatchControlVM = WatchControlVM()
    
    @State private var showAlert: Bool = false
    
    var body: some View {
        VStack {
            if viewModel.devices.isEmpty {
                emptyDeviceListView
            } else {
                deviceList
            }
        }
        .overlay {
            if viewModel.isLoading {
                loadingView
            }
        }
        .alert(viewModel.errorMessage, isPresented: $showAlert) {
            Button("OK") {
                viewModel.errorMessage = "" //resetting error
            }
        }
        .onChange(of: viewModel.errorMessage) { old, new in
            if !new.isEmpty {
                showAlert.toggle()
            }
        }
    }
    
    private var loadingView: some View {
        ProgressView()
            .tint(.primary)
    }
    
    private var emptyDeviceListView: some View {
        VStack {
            Text("No devices found")
            Button {
                viewModel.fetchData()
            } label: {
                Text("Refresh")
            }
        }
    }
    
    private var deviceList: some View {
        NavigationStack {
            List {
                ForEach($viewModel.devices) { device in
                    NavigationLink {
                        WatchDeviceDetailsView(viewModel: viewModel, device: device)
                    } label: {
                        WatchDeviceCell(viewModel: viewModel, device: device)
                    }
                    .listRowInsets(.init(top: .zero, leading: .zero, bottom: .zero, trailing: .zero))
                    .listRowBackground(Color.clear)
                }
            }
            .listStyle(.plain)
        }
    }
}

#Preview {
    WatchHomeView()
}
