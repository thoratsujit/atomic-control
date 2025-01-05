//
//  SettingsView.swift
//  AtomicControl
//
//  Created by Sujit Thorat on 13/09/24.
//

import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject private var coordinator: Coordinator
    @StateObject var viewModel = ImagePickerViewModel()
    @AppStorage(AtomicKeys.userName.value) private var userName: String = ""
    @AppStorage(AtomicKeys.homeName.value) private var homeName: String = ""
    @State private var apiKey: String = ""
    @State private var authToken: String = ""
    
    @State private var isFormValid: Bool = false
    @State private var shouldProceed: Bool = false
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Spacer()
                    EditableCircularProfileImage(viewModel: viewModel)
                    Spacer()
                }
            }
            .listRowBackground(Color.clear)
            
            Section("Your Info") {
                AtomicTextField(key: "userName",
                                label: "Name",
                                isRequired: true,
                                text: $userName,
                                validationRule: { ($0.count < 25) })
                AtomicTextField(key: "homeName",
                                label: "Home Name",
                                isRequired: true,
                                text: $homeName)
            }
            
            Section("App Theme") {
                ThemePicker(selectedOption: coordinator.$theme)
            }
            
            Section("Authentication") {
                AtomicTextField(key: "apiKey",
                                label: "API Key",
                                isRequired: true,
                                text: $apiKey)
                AtomicTextField(key: "authToken",
                                label: "Authentication Token",
                                isRequired: true,
                                text: $authToken)
            }
            
            Section {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Visit the")
                        Link("Atomberg Home Public APIs", destination: URL(string: "https://developer.atomberg-iot.com/")!)
                    }
                    Text("Follow the instructions to generate your API Key & Token.")
                }
                Text("Your data is securely stored in the iOS Keychain, ensuring it's protected and encrypted at all times.")
            }
            .font(.caption)
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
            
            Button {
                updateSettings()
            } label: {
                Text("Save")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isFormValid ? .green : .gray,
                                in: RoundedRectangle(cornerRadius: 8))
                    .foregroundStyle(.white)
            }
            .disabled(!isFormValid)
            .listRowBackground(Color.clear)
        }
        .autocorrectionDisabled()
        .navigationTitle("Settings")
        .onPreferenceChange(FieldValidationPreferenceKey.self, perform: { preference in
            isFormValid = preference.values.allSatisfy({$0 == true})
        })
    }
    
    private func saveAuthenticationDetails() {
        saveInKeychain(value: apiKey, key: .apiKey)
        saveInKeychain(value: authToken, key: .authToken)
    }
    
    private func saveInKeychain(value: String, key: AtomicKeys) {
        do {
            try KeychainManager.shared.save(value: value, forKey: key)
            if key == .refreshToken {
                shouldProceed = true
            }
        } catch {
            if key == .refreshToken {
                shouldProceed = false
            }
            let message: String
            if let keychainError = error as? KeychainError {
                message = keychainError.errorDescription ?? error.localizedDescription
            } else {
                message = error.localizedDescription
            }
            coordinator.showNotificationToast(message: message)
        }
    }
    
    private func fetchAndStoreAccessToken() {
        Task {
            do {
                let response = try await NetworkService.shared.execute(with: RefreshTokenURI())
                let refreshToken = response.message.refreshToken
                
                await MainActor.run {
                    saveInKeychain(value: refreshToken, key: .refreshToken)
                    handleNavigation()
                }
            } catch let error as NetworkError {
                coordinator.showNotificationToast(message: error.message)
            }
        }
    }
    
    private func updateSettings() {
        saveAuthenticationDetails()
        fetchAndStoreAccessToken()
    }
    
    private func handleNavigation() {
        if isFormValid && shouldProceed {
            coordinator.dismissSheet()
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(Coordinator())
}
