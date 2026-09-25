import Foundation

class DirectoryBrowser {
    static let shared = DirectoryBrowser()
    
    private let fileSystem = DefaultFileSystemManager.shared
    private let pathResolver = PathResolver.shared
    
    private init() {}
    
    func browseContainer(_ container: AppContainer) throws -> [FileItem] {
        return try fileSystem.listDirectory(at: container.dataPath)
    }
    
    func browseDirectory(at url: URL) throws -> [FileItem] {
        return try fileSystem.listDirectory(at: url)
    }
    
    func getFileDetails(at url: URL) throws -> FileItem {
        let attributes = try fileSystem.attributes(at: url)
        let isDirectory = attributes[.type] as? FileAttributeType == .typeDirectory
        let size = attributes[.size] as? UInt64
        let date = attributes[.modificationDate] as? Date
        let permissions = attributes[.posixPermissions] as? UInt16
        
        return FileItem(
            url: url,
            isDirectory: isDirectory,
            size: size,
            modificationDate: date,
            permissions: permissions.map { String($0, radix: 8) }
        )
    }
    
    func search(in container: AppContainer, query: String) throws -> [FileItem] {
        var results: [FileItem] = []
        try searchRecursive(in: container.dataPath, query: query, results: &results)
        return results
    }
    
    private func searchRecursive(in url: URL, query: String, results: inout [FileItem]) throws {
        let items = try fileSystem.listDirectory(at: url)
        
        for item in items {
            if item.name.localizedCaseInsensitiveContains(query) {
                results.append(item)
            }
            
            if item.isDirectory {
                try searchRecursive(in: item.url, query: query, results: &results)
            }
        }
    }
}
