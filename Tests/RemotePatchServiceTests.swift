import XCTest
@testable import VINIJB

final class RemotePatchServiceTests: XCTestCase {
    
    func testRemotePatchInfoCodable() throws {
        let json = """
        {
            "id": "test-id",
            "name": "Test Patch",
            "description": "Test description",
            "version": "1.0.0",
            "type": "premium",
            "status": "active",
            "created_at": "2024-01-01T00:00:00Z",
            "updated_at": "2024-01-01T00:00:00Z"
        }
        """
        
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        let patch = try decoder.decode(RemotePatchInfo.self, from: data)
        
        XCTAssertEqual(patch.id, "test-id")
        XCTAssertEqual(patch.name, "Test Patch")
        XCTAssertEqual(patch.description, "Test description")
        XCTAssertEqual(patch.version, "1.0.0")
        XCTAssertEqual(patch.type, "premium")
        XCTAssertEqual(patch.status, "active")
    }
    
    func testPatchesResponseCodable() throws {
        let json = """
        {
            "patches": [
                {
                    "id": "patch-1",
                    "name": "Patch 1",
                    "description": "Description 1",
                    "version": "1.0.0",
                    "type": "premium",
                    "created_at": "2024-01-01T00:00:00Z",
                    "updated_at": "2024-01-01T00:00:00Z"
                },
                {
                    "id": "patch-2",
                    "name": "Patch 2",
                    "description": "Description 2",
                    "version": "1.0.1",
                    "type": "free",
                    "created_at": "2024-01-02T00:00:00Z",
                    "updated_at": "2024-01-02T00:00:00Z"
                }
            ]
        }
        """
        
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        let response = try decoder.decode(PatchesResponse.self, from: data)
        
        XCTAssertEqual(response.patches.count, 2)
        XCTAssertEqual(response.patches[0].id, "patch-1")
        XCTAssertEqual(response.patches[1].id, "patch-2")
    }
}
