import Foundation

struct RemotePatchInfo: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let version: String
    let type: String
    let status: String?
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, version, type, status
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct PatchesResponse: Codable {
    let patches: [RemotePatchInfo]
}

class RemotePatchService {
    static let shared = RemotePatchService()
    
    private let apiClient = APIClient.shared
    
    private init() {}
    
    func fetchPatches() async throws -> [RemotePatchInfo] {
        let response: PatchesResponse = try await apiClient.request(endpoint: "/api/app/patches")
        return response.patches
    }
    
    func fetchPatchDetail(id: String) async throws -> RemotePatchInfo {
        return try await apiClient.request(endpoint: "/api/app/patches/\(id)")
    }
    
    func downloadPatch(id: String) async throws -> (Data, [String: String]) {
        return try await apiClient.downloadFile(endpoint: "/api/app/patches/\(id)/download")
    }
}
