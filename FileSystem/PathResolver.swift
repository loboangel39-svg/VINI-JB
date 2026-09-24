import Foundation

enum PatchDestination: Equatable, Codable {
    case appContainer
    case dataContainer
    case documents
    case library
    case applicationSupport
    case temporary
    case relative(String)
    
    var pathComponent: String {
        switch self {
        case .appContainer: return "APP_CONTAINER"
        case .dataContainer: return "DATA_CONTAINER"
        case .documents: return "Documents"
        case .library: return "Library"
        case .applicationSupport: return "Library/Application Support"
        case .temporary: return "tmp"
        case .relative(let path): return path
        }
    }
}

class PathResolver {
    static let shared = PathResolver()
    
    private let fileManager = FileManager.default
    private let jbAccess = JailbreakAccess.shared
    
    func resolvePath(for bundleID: String, destination: PatchDestination) throws -> URL {
        let containerURL = try resolveContainerURL(for: bundleID)
        
        switch destination {
        case .appContainer:
            return containerURL.appendingPathComponent("Bundle")
        case .dataContainer:
            return containerURL.appendingPathComponent("Data")
        case .documents:
            return containerURL.appendingPathComponent("Data/Documents")
        case .library:
            return containerURL.appendingPathComponent("Data/Library")
        case .applicationSupport:
            return containerURL.appendingPathComponent("Data/Library/Application Support")
        case .temporary:
            return containerURL.appendingPathComponent("Data/tmp")
        case .relative(let path):
            return containerURL.appendingPathComponent("Data/\(path)")
        }
    }
    
    private func resolveContainerURL(for bundleID: String) throws -> URL {
        // Try jailbreak paths first
        if jbAccess.isJailbreakAvailable() {
            let jbPaths = [
                "/var/mobile/Containers/Data/Application",
                "/var/mobile/Containers/Bundle/Application",
                "/private/var/mobile/Containers/Data/Application",
                "/private/var/mobile/Containers/Bundle/Application"
            ]
            
            for basePath in jbPaths {
                let base = URL(fileURLWithPath: basePath)
                if let containers = try? DefaultFileSystemManager.shared.listDirectory(at: base) {
                    for container in containers where container.isDirectory {
                        let infoPlist = container.url.appendingPathComponent(".com.apple.mobile_container_manager.metadata.plist")
                        if let data = try? Data(contentsOf: infoPlist),
                           let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
                           plist["MCMMetadataIdentifier"] as? String == bundleID {
                            return container.url
                        }
                    }
                }
            }
        }
        
        // Fallback: try to find via sandbox
        if let appURL = fileManager.urls(for: .applicationDirectory, in: .userDomainMask).first {
            return appURL
        }
        
        throw VINIError.containerNotFound
    }
    
    func listAccessibleContainers() throws -> [AppContainer] {
        var containers: [AppContainer] = []
        
        if jbAccess.isJailbreakAvailable() {
            let dataPaths = [
                "/var/mobile/Containers/Data/Application",
                "/private/var/mobile/Containers/Data/Application"
            ]
            
            for basePath in dataPaths {
                let base = URL(fileURLWithPath: basePath)
                if let items = try? DefaultFileSystemManager.shared.listDirectory(at: base) {
                    for item in items where item.isDirectory {
                        let infoPlist = item.url.appendingPathComponent(".com.apple.mobile_container_manager.metadata.plist")
                        if let data = try? Data(contentsOf: infoPlist),
                           let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
                           let bundleID = plist["MCMMetadataIdentifier"] as? String {
                            
                            let container = AppContainer(
                                uuid: item.name,
                                bundleID: bundleID,
                                dataPath: item.url.appendingPathComponent("Data"),
                                bundlePath: item.url
                            )
                            containers.append(container)
                        }
                    }
                }
            }
        }
        
        return containers.sorted { $0.bundleID < $1.bundleID }
    }
}
