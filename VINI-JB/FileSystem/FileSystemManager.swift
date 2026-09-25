import Foundation

protocol FileSystemManager {
    func exists(at path: URL) -> Bool
    func listDirectory(at path: URL) throws -> [FileItem]
    func read(at path: URL) throws -> Data
    func write(_ data: Data, to path: URL) throws
    func copy(from source: URL, to destination: URL) throws
    func move(from source: URL, to destination: URL) throws
    func delete(at path: URL) throws
    func createDirectory(at path: URL) throws
    func attributes(at path: URL) throws -> [FileAttributeKey: Any]
}

struct FileItem: Identifiable, Hashable {
    let id: String
    let name: String
    let url: URL
    let isDirectory: Bool
    let size: UInt64?
    let modificationDate: Date?
    let permissions: String?
    
    init(url: URL, isDirectory: Bool, size: UInt64? = nil, modificationDate: Date? = nil, permissions: String? = nil) {
        self.id = url.absoluteString
        self.name = url.lastPathComponent
        self.url = url
        self.isDirectory = isDirectory
        self.size = size
        self.modificationDate = modificationDate
        self.permissions = permissions
    }
}

class DefaultFileSystemManager: FileSystemManager {
    static let shared = DefaultFileSystemManager()
    
    private let fileManager = FileManager.default
    
    func exists(at path: URL) -> Bool {
        return fileManager.fileExists(atPath: path.path)
    }
    
    func listDirectory(at path: URL) throws -> [FileItem] {
        let contents = try fileManager.contentsOfDirectory(at: path, includingPropertiesForKeys: [
            .isDirectoryKey,
            .fileSizeKey,
            .contentModificationDateKey,
            .posixPermissionsKey
        ], options: [.skipsHiddenFiles])
        
        return contents.map { url in
            let values = try? url.resourceValues(forKeys: [
                .isDirectoryKey,
                .fileSizeKey,
                .contentModificationDateKey,
                .posixPermissionsKey
            ])
            
            return FileItem(
                url: url,
                isDirectory: values?.isDirectory ?? false,
                size: values?.fileSize.map { UInt64($0) },
                modificationDate: values?.contentModificationDate,
                permissions: values?.posixPermissions.map { String($0, radix: 8) }
            )
        }.sorted { $0.name < $1.name }
    }
    
    func read(at path: URL) throws -> Data {
        return try Data(contentsOf: path)
    }
    
    func write(_ data: Data, to path: URL) throws {
        try data.write(to: path, options: .atomic)
    }
    
    func copy(from source: URL, to destination: URL) throws {
        try fileManager.copyItem(at: source, to: destination)
    }
    
    func move(from source: URL, to destination: URL) throws {
        try fileManager.moveItem(at: source, to: destination)
    }
    
    func delete(at path: URL) throws {
        try fileManager.removeItem(at: path)
    }
    
    func createDirectory(at path: URL) throws {
        try fileManager.createDirectory(at: path, withIntermediateDirectories: true)
    }
    
    func attributes(at path: URL) throws -> [FileAttributeKey: Any] {
        return try fileManager.attributesOfItem(atPath: path.path)
    }
}
