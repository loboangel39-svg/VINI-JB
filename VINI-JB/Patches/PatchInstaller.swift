import Foundation

class PatchInstaller {
    static let shared = PatchInstaller()
    
    private let fileSystem = DefaultFileSystemManager.shared
    private let pathResolver = PathResolver.shared
    private let backupManager = PatchBackupManager.shared
    
    private init() {}
    
    func install(patch: PatchProject, to container: AppContainer) throws -> PatchResult {
        // Validate patch
        guard patch.isValid else {
            throw VINIError.patchInvalid
        }
        
        var filesModified: [String] = []
        
        // Process each file in the patch
        for rule in patch.rules {
            let destinationURL = try pathResolver.resolvePath(for: container.bundleID, destination: rule.destination)
            let targetURL = destinationURL.appendingPathComponent(rule.targetPath)
            
            // Create backup if file exists
            if fileSystem.exists(at: targetURL) {
                do {
                    try backupManager.createBackup(for: targetURL, patchID: patch.id)
                } catch {
                    throw VINIError.backupFailed
                }
            }
            
            // Write patch file
            do {
                try fileSystem.write(rule.fileData, to: targetURL)
                filesModified.append(targetURL.path)
            } catch {
                throw VINIError.installationFailed
            }
        }
        
        // Verify installation
        for path in filesModified {
            let url = URL(fileURLWithPath: path)
            guard fileSystem.exists(at: url) else {
                throw VINIError.verificationFailed
            }
        }
        
        return .success(
            message: "Patch installed successfully",
            backupCreated: true,
            filesModified: filesModified
        )
    }
    
    func verifyInstallation(patch: PatchProject, container: AppContainer) throws -> Bool {
        for rule in patch.rules {
            let destinationURL = try pathResolver.resolvePath(for: container.bundleID, destination: rule.destination)
            let targetURL = destinationURL.appendingPathComponent(rule.targetPath)
            
            guard fileSystem.exists(at: targetURL) else {
                return false
            }
        }
        
        return true
    }
}
