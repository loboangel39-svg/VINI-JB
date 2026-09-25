import Foundation

struct PatchProject: Identifiable, Codable {
    let id: String
    let name: String
    let version: String
    let rules: [PatchRule]
    
    var isValid: Bool {
        return !rules.isEmpty && rules.allSatisfy { $0.isValid }
    }
}

struct PatchRule: Identifiable, Codable {
    let id: String
    let targetPath: String
    let destination: PatchDestination
    let fileData: Data
    
    var isValid: Bool {
        return !targetPath.isEmpty && !fileData.isEmpty
    }
}

struct PatchFile: Codable {
    let name: String
    let destination: String
    let data: Data
}
