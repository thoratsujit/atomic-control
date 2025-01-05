//
//  OnboardingView.swift
//  AtomicControl
//
//  Created by Sujit Thorat on 12/09/24.
//

import SwiftUI

struct OnboardingView: View {
    
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
                handleOnboarding()
            } label: {
                Text("Continue \(Image(systemName: "arrow.right"))")
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
        .navigationTitle("Welcome")
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
                    navigateToHome()
                }
            } catch let error as NetworkError {
                coordinator.showNotificationToast(message: error.message)
            }
        }
    }
    
    private func handleOnboarding() {
        saveAuthenticationDetails()
        fetchAndStoreAccessToken()
    }
    
    private func navigateToHome() {
        if isFormValid && shouldProceed {
            UserDefaults.standard.setValue(true, forKey: AtomicKeys.isUserOnboarded.value)
            coordinator.push(page: .home)
        }
    }
}

// TODO: Move to separate file
struct FieldValidationPreferenceKey: PreferenceKey {
    typealias Value = [String : Bool]
    
    static var defaultValue: [String : Bool] = [:]
    
    static func reduce(value: inout [String : Bool], nextValue: () -> [String : Bool]) {
        value.merge(nextValue()) { $1 }
    }
}

// TODO: Move to separate file
struct AtomicTextField: View {
    var key: String
    var label: String
    var isRequired: Bool = false
    var contentType: UITextContentType?
    var keyboardType: UIKeyboardType = .default
    
    @Binding var text: String
    
    var validationRule: ((String) -> Bool)?
    
    @State private var isValid: Bool = true
    @State private var isUserInteracted: Bool = false
    
    private var message: String {
        if text.isEmpty {
            return "\(label) is required"
        } else {
            return "Please, enter a valid \(label)"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            TextField(label, text: $text)
                .textContentType(contentType)
                .keyboardType(keyboardType)
                .onChange(of: text) { _ in
                    isUserInteracted = true
                    validate()
                }
            
            if !isValid && isUserInteracted {
                Text("\(Image(systemName: "exclamationmark.circle")) \(message)")
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
        .preference(key: FieldValidationPreferenceKey.self, value: [key: isValid])
        .onAppear {
            validate()
        }
    }
    
    func validate() {
        if text.isEmpty {
            isValid = !isRequired
        } else if let rule = validationRule {
            isValid = rule(text)
        } else {
            isValid = true
        }
    }
}

#Preview {
    OnboardingView()
}
