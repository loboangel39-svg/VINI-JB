import Foundation
import Combine

class PatchManager: ObservableObject {
    static let shared = PatchManager()
    
    @Published var patches: [RemotePatchInfo] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private let remoteService = RemotePatchService.shared
    private let storage = PatchStorage.shared
    private let keyStore = PatchKeyStore.shared
    
    private init() {}
    
    func syncPatches() async {
        isLoading = true
        error = nil
        
        do {
            let remotePatches = try await remoteService.fetchPatches()
            
            // Remove patches no longer assigned
            let remoteIDs = Set(remotePatches.map { $0.id })
            for localPatch in patches {
                if !remoteIDs.contains(localPatch.id) {
                    try? storage.deletePatch(id: localPatch.id)
                }
            }
            
            // Download new or updated patches
            for patch in remotePatches {
                if !storage.isDownloaded(id: patch.id) || storage.localVersion(id: patch.id) != patch.version {
                    do {
                        try await downloadPatch(patch)
                    } catch {
                        print("Failed to download patch \(patch.name): \(error)")
                    }
                }
            }
            
            self.patches = remotePatches
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    private func downloadPatch(_ patch: RemotePatchInfo) async throws {
        let (data, headers) = try await remoteService.downloadPatch(id: patch.id)
        
        // Save patch file
        try storage.savePatch(data: data, id: patch.id, version: patch.version)
        
        // Save content key
        if let contentKey = headers["X-Content-Key"] {
            keyStore.saveKey(contentKey, forPatchID: patch.id)
        }
    }
    
    func isDownloaded(_ patch: RemotePatchInfo) -> Bool {
        return storage.isDownloaded(id: patch.id)
    }
    
    func localVersion(_ patch: RemotePatchInfo) -> String? {
        return storage.localVersion(id: patch.id)
    }
    
    func hasUpdate(_ patch: RemotePatchInfo) -> Bool {
        guard let localVersion = localVersion(patch) else { return false }
        return localVersion != patch.version
    }
    
    func patchData(_ patch: RemotePatchInfo) -> Data? {
        return storage.loadPatchData(id: patch.id)
    }
    
    func deleteLocalPatch(_ patch: RemotePatchInfo) throws {
        try storage.deletePatch(id: patch.id)
        keyStore.deleteKey(forPatchID: patch.id)
    }
}

class PatchStorage {
    static let shared = PatchStorage()
    
    private var storageDirectory: URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documents.appendingPathComponent("RemotePatches")
    }
    
    private init() {
        try? FileManager.default.createDirectory(at: storageDirectory, withIntermediateDirectories: true)
    }
    
    func isDownloaded(id: String) -> Bool {
        let fileURL = storageDirectory.appendingPathComponent("\(id).3105")
        return FileManager.default.fileExists(atPath: fileURL.path)
    }
    
    func localVersion(id: String) -> String? {
        let metaURL = storageDirectory.appendingPathComponent("\(id).meta")
        guard let data = try? Data(contentsOf: metaURL),
              let meta = try? JSONDecoder().decode(PatchMeta.self, from: data) else {
            return nil
        }
        return meta.version
    }
    
    func savePatch(data: Data, id: String, version: String) throws {
        let fileURL = storageDirectory.appendingPathComponent("\(id).3105")
        try data.write(to: fileURL, options: .atomic)
        
        let meta = PatchMeta(id: id, version: version, downloadDate: Date())
        let metaURL = storageDirectory.appendingPathComponent("\(id).meta")
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let metaData = try encoder.encode(meta)
        try metaData.write(to: metaURL, options: .atomic)
    }
    
    func loadPatchData(id: String) -> Data? {
        let fileURL = storageDirectory.appendingPathComponent("\(id).3105")
        return try? Data(contentsOf: fileURL)
    }
    
    func deletePatch(id: String) throws {
        let fileURL = storageDirectory.appendingPathComponent("\(id).3105")
        let metaURL = storageDirectory.appendingPathComponent("\(id).meta")
        try? FileManager.default.removeItem(at: fileURL)
        try? FileManager.default.removeItem(at: metaURL)
    }
}

struct PatchMeta: Codable {
    let id: String
    let version: String
    let downloadDate: Date
}

class PatchKeyStore {
    static let shared = PatchKeyStore()
    
    private let serviceName = "com.apple.mobile.MobileHouseArrest.patch-keys"
    
    private init() {}
    
    func saveKey(_ key: String, forPatchID patchID: String) {
        guard let data = key.data(using: .utf8) else { return }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: patchID,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]
        
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
    
    func loadKey(forPatchID patchID: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: patchID,
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
    
    func deleteKey(forPatchID patchID: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: patchID
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}

import Security
