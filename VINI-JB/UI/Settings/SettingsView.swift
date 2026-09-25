import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var loginManager: LoginManager
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Account")) {
                    if let username = KeychainManager.shared.loadUsername() {
                        InfoRow(title: "User", value: username)
                    }
                    
                    Button("Logout", role: .destructive) {
                        loginManager.logout()
                    }
                    .foregroundColor(.red)
                }
                
                Section(header: Text("About")) {
                    InfoRow(title: "Version", value: "1.0.0")
                    InfoRow(title: "Build", value: "1")
                }
                
                Section(header: Text("System")) {
                    InfoRow(title: "iOS", value: appState.deviceInfo?.iosVersion ?? "Unknown")
                    InfoRow(title: "Device", value: appState.deviceInfo?.deviceModel ?? "Unknown")
                    InfoRow(title: "Jailbreak", value: appState.isJailbreakAvailable ? "Available" : "Not Available")
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Settings")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
