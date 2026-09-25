import Foundation
import Combine

class LoginManager: ObservableObject {
    @Published var isLoggedIn = false
    @Published var isLoading = false
    @Published var error: String?
    
    private let apiClient = APIClient.shared
    private let keychain = KeychainManager.shared
    
    func login(licenseKey: String) async {
        isLoading = true
        error = nil
        
        struct LoginRequest: Codable {
            let licenseKey: String
            let hwid: String
        }
        
        struct LoginResponse: Codable {
            let token: String
            let username: String?
        }
        
        do {
            let hwid = keychain.getOrCreatePersistentHWID()
            let request = LoginRequest(licenseKey: licenseKey, hwid: hwid)
            let encoder = JSONEncoder()
            let body = try encoder.encode(request)
            
            let response: LoginResponse = try await apiClient.request(
                endpoint: "/api/app/validate-license",
                method: "POST",
                body: body,
                requiresAuth: false
            )
            
            keychain.saveAuthToken(response.token)
            keychain.saveLicenseKey(licenseKey)
            if let username = response.username {
                keychain.saveUsername(username)
            }
            
            isLoggedIn = true
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func tryAutoLogin() async {
        guard let licenseKey = keychain.loadLicenseKey() else {
            return
        }
        
        await login(licenseKey: licenseKey)
    }
    
    func verifySession() async {
        guard keychain.loadAuthToken() != nil else {
            isLoggedIn = false
            return
        }
        
        // Try to fetch patches to verify session
        do {
            _ = try await apiClient.request(endpoint: "/api/app/patches") as PatchesResponse
            isLoggedIn = true
        } catch {
            if case VINIError.authenticationRequired = error {
                isLoggedIn = false
            }
        }
    }
    
    func logout() {
        keychain.saveAuthToken("")
        isLoggedIn = false
    }
    
    func forceLogout() {
        keychain.clearAll()
        isLoggedIn = false
    }
}
