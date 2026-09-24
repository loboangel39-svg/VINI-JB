import XCTest
@testable import VINIJB

final class PatchModelsTests: XCTestCase {
    
    func testPatchDestinationCodable() throws {
        let destinations: [PatchDestination] = [
            .appContainer,
            .dataContainer,
            .documents,
            .library,
            .applicationSupport,
            .temporary,
            .relative("custom/path")
        ]
        
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        for destination in destinations {
            let data = try encoder.encode(destination)
            let decoded = try decoder.decode(PatchDestination.self, from: data)
            XCTAssertEqual(destination, decoded)
        }
    }
    
    func testPatchRuleValidation() {
        let validRule = PatchRule(
            id: "test-id",
            targetPath: "test.txt",
            destination: .documents,
            fileData: "test data".data(using: .utf8)!
        )
        XCTAssertTrue(validRule.isValid)
        
        let invalidEmptyPath = PatchRule(
            id: "test-id",
            targetPath: "",
            destination: .documents,
            fileData: "test data".data(using: .utf8)!
        )
        XCTAssertFalse(invalidEmptyPath.isValid)
        
        let invalidEmptyData = PatchRule(
            id: "test-id",
            targetPath: "test.txt",
            destination: .documents,
            fileData: Data()
        )
        XCTAssertFalse(invalidEmptyData.isValid)
    }
    
    func testPatchProjectValidation() {
        let validProject = PatchProject(
            id: "test-id",
            name: "Test Patch",
            version: "1.0.0",
            rules: [
                PatchRule(
                    id: "rule-1",
                    targetPath: "test.txt",
                    destination: .documents,
                    fileData: "test data".data(using: .utf8)!
                )
            ]
        )
        XCTAssertTrue(validProject.isValid)
        
        let invalidEmptyRules = PatchProject(
            id: "test-id",
            name: "Test Patch",
            version: "1.0.0",
            rules: []
        )
        XCTAssertFalse(invalidEmptyRules.isValid)
    }
    
    func testPatchResultSuccess() {
        let result = PatchResult.success(
            message: "Success",
            backupCreated: true,
            filesModified: ["/path/to/file"]
        )
        
        XCTAssertTrue(result.success)
        XCTAssertEqual(result.message, "Success")
        XCTAssertTrue(result.backupCreated)
        XCTAssertEqual(result.filesModified.count, 1)
    }
    
    func testPatchResultFailure() {
        let result = PatchResult.failure(message: "Failed")
        
        XCTAssertFalse(result.success)
        XCTAssertEqual(result.message, "Failed")
        XCTAssertFalse(result.backupCreated)
        XCTAssertTrue(result.filesModified.isEmpty)
    }
}
