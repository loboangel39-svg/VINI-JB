import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var loginManager: LoginManager
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationStack {
            List {
                Section("Account") {
                    if let username = KeychainManager.shared.loadUsername() {
                        LabeledContent("User", value: username)
                    }
                    
                    Button("Logout", role: .destructive) {
                        loginManager.logout()
                    }
                    .foregroundColor(.red)
                }
                
                Section("About") {
                    LabeledContent("Version", value: "1.0.0")
                    LabeledContent("Build", value: "1")
                }
                
                Section("System") {
                    LabeledContent("iOS", value: appState.deviceInfo?.iosVersion ?? "Unknown")
                    LabeledContent("Device", value: appState.deviceInfo?.deviceModel ?? "Unknown")
                    LabeledContent("Jailbreak", value: appState.isJailbreakAvailable ? "Available" : "Not Available")
                }
            }
            .navigationTitle("Settings")
        }
    }
}
