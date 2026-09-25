import Foundation

struct AppContainer: Identifiable, Hashable {
    let id: String
    let uuid: String
    let bundleID: String
    let dataPath: URL
    let bundlePath: URL
    
    init(uuid: String, bundleID: String, dataPath: URL, bundlePath: URL) {
        self.id = uuid
        self.uuid = uuid
        self.bundleID = bundleID
        self.dataPath = dataPath
        self.bundlePath = bundlePath
    }
    
    var displayName: String {
        return bundleID.components(separatedBy: ".").last ?? bundleID
    }
    
    var documentsURL: URL {
        return dataPath.appendingPathComponent("Documents")
    }
    
    var libraryURL: URL {
        return dataPath.appendingPathComponent("Library")
    }
    
    var tmpURL: URL {
        return dataPath.appendingPathComponent("tmp")
    }
    
    var applicationSupportURL: URL {
        return dataPath.appendingPathComponent("Library/Application Support")
    }
}

struct PatchResult {
    let success: Bool
    let message: String
    let backupCreated: Bool
    let filesModified: [String]
    
    static func success(message: String, backupCreated: Bool, filesModified: [String]) -> PatchResult {
        return PatchResult(success: true, message: message, backupCreated: backupCreated, filesModified: filesModified)
    }
    
    static func failure(message: String) -> PatchResult {
        return PatchResult(success: false, message: message, backupCreated: false, filesModified: [])
    }
}

enum VINIError: Error, LocalizedError {
    case jailbreakAccessUnavailable
    case containerNotFound
    case permissionDenied
    case patchInvalid
    case backupFailed
    case installationFailed
    case verificationFailed
    case fileNotFound
    case networkError(String)
    case authenticationRequired
    
    var errorDescription: String? {
        switch self {
        case .jailbreakAccessUnavailable:
            return "Jailbreak access is not available on this device"
        case .containerNotFound:
            return "App container not found"
        case .permissionDenied:
            return "Permission denied for this operation"
        case .patchInvalid:
            return "Patch file is invalid or corrupted"
        case .backupFailed:
            return "Failed to create backup"
        case .installationFailed:
            return "Failed to install patch"
        case .verificationFailed:
            return "Patch verification failed"
        case .fileNotFound:
            return "File not found"
        case .networkError(let message):
            return "Network error: \(message)"
        case .authenticationRequired:
            return "Authentication required"
        }
    }
}
