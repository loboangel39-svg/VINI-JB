import Foundation

class PatchRestoreManager {
    static let shared = PatchRestoreManager()
    
    private let fileSystem = DefaultFileSystemManager.shared
    private let backupManager = PatchBackupManager.shared
    
    private init() {}
    
    func restore(patchID: String) throws -> PatchResult {
        guard let backup = try backupManager.getBackup(for: patchID) else {
            throw VINIError.fileNotFound
        }
        
        var filesRestored: [String] = []
        
        for file in backup.files {
            let originalURL = URL(fileURLWithPath: backup.metadata.originalPath)
                .deletingLastPathComponent()
                .appendingPathComponent(file.name)
            
            // Restore file from backup
            do {
                try fileSystem.copy(from: file.url, to: originalURL)
                filesRestored.append(originalURL.path)
            } catch {
                throw VINIError.installationFailed
            }
        }
        
        // Verify restoration
        for path in filesRestored {
            let url = URL(fileURLWithPath: path)
            guard fileSystem.exists(at: url) else {
                throw VINIError.verificationFailed
            }
        }
        
        return .success(
            message: "Patch restored successfully",
            backupCreated: false,
            filesModified: filesRestored
        )
    }
    
    func hasBackup(for patchID: String) -> Bool {
        return (try? backupManager.getBackup(for: patchID)) != nil
    }
}
