import XCTest
@testable import VINIJB

final class PathResolverTests: XCTestCase {
    
    var pathResolver: PathResolver!
    
    override func setUp() {
        super.setUp()
        pathResolver = PathResolver.shared
    }
    
    override func tearDown() {
        pathResolver = nil
        super.tearDown()
    }
    
    func testPatchDestinationPathComponents() {
        XCTAssertEqual(PatchDestination.documents.pathComponent, "Documents")
        XCTAssertEqual(PatchDestination.library.pathComponent, "Library")
        XCTAssertEqual(PatchDestination.applicationSupport.pathComponent, "Library/Application Support")
        XCTAssertEqual(PatchDestination.temporary.pathComponent, "tmp")
        XCTAssertEqual(PatchDestination.relative("custom/path").pathComponent, "custom/path")
    }
    
    func testPatchDestinationEquality() {
        XCTAssertEqual(PatchDestination.documents, PatchDestination.documents)
        XCTAssertNotEqual(PatchDestination.documents, PatchDestination.library)
        XCTAssertEqual(PatchDestination.relative("test"), PatchDestination.relative("test"))
        XCTAssertNotEqual(PatchDestination.relative("test1"), PatchDestination.relative("test2"))
    }
    
    func testPatchDestinationCodable() throws {
        let destinations: [PatchDestination] = [
            .documents,
            .library,
            .applicationSupport,
            .temporary,
            .relative("custom")
        ]
        
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        for destination in destinations {
            let data = try encoder.encode(destination)
            let decoded = try decoder.decode(PatchDestination.self, from: data)
            XCTAssertEqual(destination, decoded)
        }
    }
}
