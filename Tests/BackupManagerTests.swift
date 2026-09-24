import XCTest
@testable import VINIJB

final class BackupManagerTests: XCTestCase {
    
    var backupManager: PatchBackupManager!
    var fileSystem: DefaultFileSystemManager!
    var testDirectory: URL!
    
    override func setUp() {
        super.setUp()
        backupManager = PatchBackupManager.shared
        fileSystem = DefaultFileSystemManager.shared
        
        // Create temporary test directory
        let tempDir = FileManager.default.temporaryDirectory
        testDirectory = tempDir.appendingPathComponent("VINIJBBackupTests-\(UUID().uuidString)")
        try? fileSystem.createDirectory(at: testDirectory)
    }
    
    override func tearDown() {
        // Clean up test directory
        try? fileSystem.delete(at: testDirectory)
        backupManager = nil
        fileSystem = nil
        testDirectory = nil
        super.tearDown()
    }
    
    func testBackupMetadataCodable() throws {
        let metadata = BackupMetadata(
            patchID: "test-patch-id",
            originalPath: "/path/to/original",
            backupDate: Date(),
            fileName: "test.txt"
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(metadata)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(BackupMetadata.self, from: data)
        
        XCTAssertEqual(decoded.patchID, metadata.patchID)
        XCTAssertEqual(decoded.originalPath, metadata.originalPath)
        XCTAssertEqual(decoded.fileName, metadata.fileName)
    }
    
    func testListBackupsEmpty() throws {
        let backups = try backupManager.listBackups()
        // Should not throw and should return empty or existing backups
        XCTAssertNotNil(backups)
    }
}
