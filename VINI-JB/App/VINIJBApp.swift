import SwiftUI

@main
struct VINIJBApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var loginManager = LoginManager()
    @StateObject private var patchManager = PatchManager.shared
    
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(loginManager)
                .environmentObject(patchManager)
                .task {
                    await loginManager.tryAutoLogin()
                }
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                Task {
                    await loginManager.verifySession()
                }
            }
        }
    }
}

class AppState: ObservableObject {
    @Published var isJailbreakAvailable = false
    @Published var filesystemAccessLevel: AccessLevel = .sandboxOnly
    @Published var deviceInfo: DeviceInfo?
    
    init() {
        checkJailbreakAccess()
    }
    
    private func checkJailbreakAccess() {
        let jbAccess = JailbreakAccess.shared
        isJailbreakAvailable = jbAccess.isJailbreakAvailable()
        filesystemAccessLevel = jbAccess.currentAccessLevel()
        deviceInfo = jbAccess.getDeviceInfo()
    }
}

struct DeviceInfo {
    let iosVersion: String
    let deviceModel: String
    let architecture: String
    let jailbreakType: String?
}
