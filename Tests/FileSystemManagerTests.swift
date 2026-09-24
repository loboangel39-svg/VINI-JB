import XCTest
@testable import VINIJB

final class FileSystemManagerTests: XCTestCase {
    
    var fileSystem: DefaultFileSystemManager!
    var testDirectory: URL!
    
    override func setUp() {
        super.setUp()
        fileSystem = DefaultFileSystemManager.shared
        
        // Create temporary test directory
        let tempDir = FileManager.default.temporaryDirectory
        testDirectory = tempDir.appendingPathComponent("VINIJBTests-\(UUID().uuidString)")
        try? fileSystem.createDirectory(at: testDirectory)
    }
    
    override func tearDown() {
        // Clean up test directory
        try? fileSystem.delete(at: testDirectory)
        fileSystem = nil
        testDirectory = nil
        super.tearDown()
    }
    
    func testCreateDirectory() throws {
        let newDir = testDirectory.appendingPathComponent("testDir")
        
        XCTAssertFalse(fileSystem.exists(at: newDir))
        
        try fileSystem.createDirectory(at: newDir)
        
        XCTAssertTrue(fileSystem.exists(at: newDir))
    }
    
    func testWriteAndReadFile() throws {
        let fileURL = testDirectory.appendingPathComponent("test.txt")
        let testData = "Hello, World!".data(using: .utf8)!
        
        try fileSystem.write(testData, to: fileURL)
        
        XCTAssertTrue(fileSystem.exists(at: fileURL))
        
        let readData = try fileSystem.read(at: fileURL)
        XCTAssertEqual(readData, testData)
    }
    
    func testCopyFile() throws {
        let sourceURL = testDirectory.appendingPathComponent("source.txt")
        let destURL = testDirectory.appendingPathComponent("dest.txt")
        let testData = "Test data".data(using: .utf8)!
        
        try fileSystem.write(testData, to: sourceURL)
        try fileSystem.copy(from: sourceURL, to: destURL)
        
        XCTAssertTrue(fileSystem.exists(at: sourceURL))
        XCTAssertTrue(fileSystem.exists(at: destURL))
        
        let copiedData = try fileSystem.read(at: destURL)
        XCTAssertEqual(copiedData, testData)
    }
    
    func testMoveFile() throws {
        let sourceURL = testDirectory.appendingPathComponent("source.txt")
        let destURL = testDirectory.appendingPathComponent("dest.txt")
        let testData = "Test data".data(using: .utf8)!
        
        try fileSystem.write(testData, to: sourceURL)
        try fileSystem.move(from: sourceURL, to: destURL)
        
        XCTAssertFalse(fileSystem.exists(at: sourceURL))
        XCTAssertTrue(fileSystem.exists(at: destURL))
        
        let movedData = try fileSystem.read(at: destURL)
        XCTAssertEqual(movedData, testData)
    }
    
    func testDeleteFile() throws {
        let fileURL = testDirectory.appendingPathComponent("test.txt")
        let testData = "Test data".data(using: .utf8)!
        
        try fileSystem.write(testData, to: fileURL)
        XCTAssertTrue(fileSystem.exists(at: fileURL))
        
        try fileSystem.delete(at: fileURL)
        XCTAssertFalse(fileSystem.exists(at: fileURL))
    }
    
    func testListDirectory() throws {
        // Create test files and directories
        let file1 = testDirectory.appendingPathComponent("file1.txt")
        let file2 = testDirectory.appendingPathComponent("file2.txt")
        let subDir = testDirectory.appendingPathComponent("subdir")
        
        try fileSystem.write("data1".data(using: .utf8)!, to: file1)
        try fileSystem.write("data2".data(using: .utf8)!, to: file2)
        try fileSystem.createDirectory(at: subDir)
        
        let items = try fileSystem.listDirectory(at: testDirectory)
        
        XCTAssertEqual(items.count, 3)
        
        let fileItems = items.filter { !$0.isDirectory }
        let dirItems = items.filter { $0.isDirectory }
        
        XCTAssertEqual(fileItems.count, 2)
        XCTAssertEqual(dirItems.count, 1)
    }
    
    func testListDirectorySorted() throws {
        let fileC = testDirectory.appendingPathComponent("c.txt")
        let fileA = testDirectory.appendingPathComponent("a.txt")
        let fileB = testDirectory.appendingPathComponent("b.txt")
        
        try fileSystem.write("data".data(using: .utf8)!, to: fileC)
        try fileSystem.write("data".data(using: .utf8)!, to: fileA)
        try fileSystem.write("data".data(using: .utf8)!, to: fileB)
        
        let items = try fileSystem.listDirectory(at: testDirectory)
        
        XCTAssertEqual(items[0].name, "a.txt")
        XCTAssertEqual(items[1].name, "b.txt")
        XCTAssertEqual(items[2].name, "c.txt")
    }
    
    func testFileAttributes() throws {
        let fileURL = testDirectory.appendingPathComponent("test.txt")
        let testData = "Test data".data(using: .utf8)!
        
        try fileSystem.write(testData, to: fileURL)
        
        let attributes = try fileSystem.attributes(at: fileURL)
        
        XCTAssertNotNil(attributes[.size])
        XCTAssertNotNil(attributes[.modificationDate])
    }
}
