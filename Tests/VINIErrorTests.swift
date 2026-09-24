import XCTest
@testable import VINIJB

final class VINIErrorTests: XCTestCase {
    
    func testErrorDescriptions() {
        let errors: [(VINIError, String)] = [
            (.jailbreakAccessUnavailable, "Jailbreak access is not available on this device"),
            (.containerNotFound, "App container not found"),
            (.permissionDenied, "Permission denied for this operation"),
            (.patchInvalid, "Patch file is invalid or corrupted"),
            (.backupFailed, "Failed to create backup"),
            (.installationFailed, "Failed to install patch"),
            (.verificationFailed, "Patch verification failed"),
            (.fileNotFound, "File not found"),
            (.authenticationRequired, "Authentication required")
        ]
        
        for (error, expectedDescription) in errors {
            XCTAssertEqual(error.errorDescription, expectedDescription)
        }
    }
    
    func testNetworkErrorDescription() {
        let error = VINIError.networkError("Connection timeout")
        XCTAssertEqual(error.errorDescription, "Network error: Connection timeout")
    }
}
