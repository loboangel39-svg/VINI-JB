import SwiftUI

struct ContentView: View {
    @EnvironmentObject var loginManager: LoginManager
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Group {
            if loginManager.isLoggedIn {
                MainTabView()
            } else {
                LoginView()
            }
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(0)
            
            AppsView()
                .tabItem {
                    Label("Apps", systemImage: "app.badge")
                }
                .tag(1)
            
            PatchesView()
                .tabItem {
                    Label("Patches", systemImage: "puzzlepiece")
                }
                .tag(2)
            
            BackupsView()
                .tabItem {
                    Label("Backups", systemImage: "arrow.clockwise")
                }
                .tag(3)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(4)
        }
    }
}
