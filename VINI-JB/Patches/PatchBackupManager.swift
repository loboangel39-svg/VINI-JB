import Foundation

class PatchBackupManager {
    static let shared = PatchBackupManager()
    
    private let fileSystem = DefaultFileSystemManager.shared
    
    private var backupDirectory: URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documents.appendingPathComponent("VINI/Backups")
    }
    
    private init() {}
    
    func createBackup(for fileURL: URL, patchID: String) throws {
        let backupDir = backupDirectory.appendingPathComponent(patchID).appendingPathComponent("files")
        try fileSystem.createDirectory(at: backupDir)
        
        let backupFileURL = backupDir.appendingPathComponent(fileURL.lastPathComponent)
        
        // Don't overwrite existing backup without warning
        if fileSystem.exists(at: backupFileURL) {
            throw VINIError.backupFailed
        }
        
        try fileSystem.copy(from: fileURL, to: backupFileURL)
        
        // Save metadata
        let metadata = BackupMetadata(
            patchID: patchID,
            originalPath: fileURL.path,
            backupDate: Date(),
            fileName: fileURL.lastPathComponent
        )
        
        let metadataURL = backupDirectory.appendingPathComponent(patchID).appendingPathComponent("metadata.json")
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(metadata)
        try fileSystem.write(data, to: metadataURL)
    }
    
    func getBackup(for patchID: String) throws -> BackupInfo? {
        let metadataURL = backupDirectory.appendingPathComponent(patchID).appendingPathComponent("metadata.json")
        
        guard fileSystem.exists(at: metadataURL) else {
            return nil
        }
        
        let data = try fileSystem.read(at: metadataURL)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let metadata = try decoder.decode(BackupMetadata.self, from: data)
        
        let backupDir = backupDirectory.appendingPathComponent(patchID).appendingPathComponent("files")
        let files = try fileSystem.listDirectory(at: backupDir)
        
        return BackupInfo(metadata: metadata, files: files)
    }
    
    func listBackups() throws -> [BackupInfo] {
        guard fileSystem.exists(at: backupDirectory) else {
            return []
        }
        
        let patchDirs = try fileSystem.listDirectory(at: backupDirectory)
        var backups: [BackupInfo] = []
        
        for dir in patchDirs where dir.isDirectory {
            if let backup = try? getBackup(for: dir.name) {
                backups.append(backup)
            }
        }
        
        return backups.sorted { $0.metadata.backupDate > $1.metadata.backupDate }
    }
    
    func deleteBackup(for patchID: String) throws {
        let backupDir = backupDirectory.appendingPathComponent(patchID)
        try fileSystem.delete(at: backupDir)
    }
}

struct BackupMetadata: Codable {
    let patchID: String
    let originalPath: String
    let backupDate: Date
    let fileName: String
}

struct BackupInfo {
    let metadata: BackupMetadata
    let files: [FileItem]
}
