import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var loginManager: LoginManager
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Device Status")) {
                    if let deviceInfo = appState.deviceInfo {
                        InfoRow(title: "iOS Version", value: deviceInfo.iosVersion)
                        InfoRow(title: "Device", value: deviceInfo.deviceModel)
                        InfoRow(title: "Architecture", value: deviceInfo.architecture)
                        
                        if let jbType = deviceInfo.jailbreakType {
                            InfoRow(title: "Jailbreak", value: jbType)
                        } else {
                            InfoRow(title: "Jailbreak", value: "Not Detected")
                                .foregroundColor(.red)
                        }
                    }
                }
                
                Section(header: Text("System")) {
                    InfoRow(title: "Access Level", value: appState.filesystemAccessLevel.rawValue)
                    
                    NavigationLink(destination: DiagnosticsView()) {
                        Text("Diagnostics")
                    }
                }
                
                Section {
                    Button("Logout", role: .destructive) {
                        loginManager.logout()
                    }
                    .foregroundColor(.red)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("VINI-JB")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}
