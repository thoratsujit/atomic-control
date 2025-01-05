//
//  HomeView.swift
//  AtomicControl
//
//  Created by Sujit Thorat on 04/09/24.
//

import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject private var coordinator: Coordinator
    @StateObject var viewModel: DeviceViewModel = DeviceViewModel()
    
    var body: some View {
        VStack(spacing: .zero) {
            headerView
            if viewModel.devices.isEmpty {
                emptyDeviceListView
            } else {
                deviceListView
            }
        }
        .navigationBarBackButtonHidden()
        .onChange(of: viewModel.errorMessage) { message in
            if !message.isEmpty {
                coordinator.showNotificationToast(message: message)
                viewModel.errorMessage = "" //resetting error
            }
        }
        .overlay {
            if viewModel.isLoading {
                loadingView
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            profilePicture
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading) {
                Text("Hello, \(viewModel.userName)")
                    .font(.title3)
                Text("Welcome to \(viewModel.homeName)")
                    .font(.headline)
            }
            Spacer()
            IconicButton(icon: "gear") {
                // To settings or profile or switch home
                coordinator.presentSheet(.settings)
            }
        }
        .padding(16)
        .background(.bar)
    }
    
    @ViewBuilder
    private var profilePicture: some View {
        if let profilePic = LocalFileManager.shared.getImage(imageName: "profile-pic", folderName: "atomicControl") {
            Image(uiImage: profilePic)
                .resizable()
        } else {
            Image(systemName: "person.crop.circle")
                .resizable()
        }
    }
    
    private var deviceListView: some View {
        ScrollView {
            LazyVStack {
                ForEach($viewModel.devices) { device in
                    DeviceCell(viewModel: viewModel, device: device)
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .onTapGesture {
                            coordinator.push(page: .details(viewModel, device))
                        }
                }
            }
            .padding(.bottom, 48)
        }
        .refreshable {
            viewModel.fetchData()
        }
    }
    
    private var emptyDeviceListView: some View {
        VStack {
            Text("No Devices Found")
            Button {
                viewModel.fetchData()
            } label: {
                Text("\(Image(systemName: "arrow.clockwise")) Refresh")
                    .font(.headline)
                    .padding()
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
                    .dropShadow()
            }
        }
        .foregroundStyle(.primary)
        .frame(maxHeight: .infinity)
    }
    
    private var loadingView: some View {
        VStack {
            ProgressView()
                .tint(.primary)
                .padding()
                .background(.thinMaterial,
                            in: RoundedRectangle(cornerRadius: 8))
        }
        .frame(maxHeight: .infinity)
    }
}

#Preview {
    HomeView()
        .environmentObject(Coordinator())
}
