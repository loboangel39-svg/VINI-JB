import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var loginManager: LoginManager
    
    var body: some View {
        NavigationStack {
            List {
                Section("Device Status") {
                    if let deviceInfo = appState.deviceInfo {
                        LabeledContent("iOS Version", value: deviceInfo.iosVersion)
                        LabeledContent("Device", value: deviceInfo.deviceModel)
                        LabeledContent("Architecture", value: deviceInfo.architecture)
                        
                        if let jbType = deviceInfo.jailbreakType {
                            LabeledContent("Jailbreak", value: jbType)
                        } else {
                            LabeledContent("Jailbreak", value: "Not Detected")
                                .foregroundColor(.red)
                        }
                    }
                }
                
                Section("System") {
                    LabeledContent("Access Level", value: appState.filesystemAccessLevel.rawValue)
                    
                    NavigationLink("Diagnostics") {
                        DiagnosticsView()
                    }
                }
                
                Section {
                    Button("Logout", role: .destructive) {
                        loginManager.logout()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("VINI-JB")
        }
    }
}
