import Foundation
import Security

class KeychainManager {
    static let shared = KeychainManager()
    
    private let serviceName = "com.vini.keychain"
    
    private init() {}
    
    // Auth Token
    func saveAuthToken(_ token: String) {
        save(key: "vini_auth_token", value: token)
    }
    
    func loadAuthToken() -> String? {
        return load(key: "vini_auth_token")
    }
    
    // License Key
    func saveLicenseKey(_ key: String) {
        save(key: "vini_license_key", value: key)
    }
    
    func loadLicenseKey() -> String? {
        return load(key: "vini_license_key")
    }
    
    // HWID
    func saveHWID(_ hwid: String) {
        save(key: "vini_hwid", value: hwid)
    }
    
    func loadHWID() -> String? {
        return load(key: "vini_hwid")
    }
    
    func getOrCreatePersistentHWID() -> String {
        if let existing = loadHWID() {
            return existing
        }
        
        let newHWID = UUID().uuidString
        saveHWID(newHWID)
        return newHWID
    }
    
    // Username
    func saveUsername(_ username: String) {
        save(key: "vini_username", value: username)
    }
    
    func loadUsername() -> String? {
        return load(key: "vini_username")
    }
    
    // Clear all
    func clearAll() {
        let keys = ["vini_auth_token", "vini_license_key", "vini_hwid", "vini_username"]
        for key in keys {
            delete(key: key)
        }
    }
    
    // MARK: - Private Methods
    
    private func save(key: String, value: String) {
        guard let data = value.data(using: .utf8) else { return }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]
        
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
    
    private func load(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess, let data = result as? Data else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    private func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}
