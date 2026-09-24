import Foundation

class ContainerManager {
    static let shared = ContainerManager()
    
    private let pathResolver = PathResolver.shared
    private let fileSystem = DefaultFileSystemManager.shared
    
    private init() {}
    
    func discoverContainers() throws -> [AppContainer] {
        return try pathResolver.listAccessibleContainers()
    }
    
    func getContainer(for bundleID: String) throws -> AppContainer {
        let containers = try discoverContainers()
        guard let container = containers.first(where: { $0.bundleID == bundleID }) else {
            throw VINIError.containerNotFound
        }
        return container
    }
    
    func listContainerContents(_ container: AppContainer) throws -> [FileItem] {
        return try fileSystem.listDirectory(at: container.dataPath)
    }
    
    func getContainerDirectories(_ container: AppContainer) -> [FileItem] {
        let directories = [
            ("Documents", container.documentsURL),
            ("Library", container.libraryURL),
            ("tmp", container.tmpURL),
            ("Application Support", container.applicationSupportURL)
        ]
        
        return directories.compactMap { name, url in
            guard fileSystem.exists(at: url) else { return nil }
            return FileItem(url: url, isDirectory: true)
        }
    }
}
