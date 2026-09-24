import XCTest
@testable import VINIJB

final class AppContainerTests: XCTestCase {
    
    func testAppContainerDisplayName() {
        let container = AppContainer(
            uuid: "test-uuid",
            bundleID: "com.example.app",
            dataPath: URL(fileURLWithPath: "/data"),
            bundlePath: URL(fileURLWithPath: "/bundle")
        )
        
        XCTAssertEqual(container.displayName, "app")
    }
    
    func testAppContainerURLs() {
        let dataPath = URL(fileURLWithPath: "/var/mobile/Containers/Data/Application/test-uuid")
        let container = AppContainer(
            uuid: "test-uuid",
            bundleID: "com.example.app",
            dataPath: dataPath,
            bundlePath: URL(fileURLWithPath: "/bundle")
        )
        
        XCTAssertTrue(container.documentsURL.path.hasSuffix("Documents"))
        XCTAssertTrue(container.libraryURL.path.hasSuffix("Library"))
        XCTAssertTrue(container.tmpURL.path.hasSuffix("tmp"))
        XCTAssertTrue(container.applicationSupportURL.path.hasSuffix("Library/Application Support"))
    }
    
    func testAppContainerEquality() {
        let container1 = AppContainer(
            uuid: "uuid-1",
            bundleID: "com.example.app1",
            dataPath: URL(fileURLWithPath: "/data1"),
            bundlePath: URL(fileURLWithPath: "/bundle1")
        )
        
        let container2 = AppContainer(
            uuid: "uuid-2",
            bundleID: "com.example.app2",
            dataPath: URL(fileURLWithPath: "/data2"),
            bundlePath: URL(fileURLWithPath: "/bundle2")
        )
        
        XCTAssertNotEqual(container1, container2)
        XCTAssertEqual(container1, container1)
    }
}
