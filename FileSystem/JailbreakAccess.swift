import Foundation
import UIKit

enum AccessLevel: String, Codable {
    case sandboxOnly = "sandbox"
    case jailbreak = "jailbreak"
    case extended = "extended"
}

class JailbreakAccess {
    static let shared = JailbreakAccess()
    
    private init() {}
    
    func isJailbreakAvailable() -> Bool {
        return currentAccessLevel() != .sandboxOnly
    }
    
    func currentAccessLevel() -> AccessLevel {
        // Check for common jailbreak paths
        let jbPaths = [
            "/Applications/Cydia.app",
            "/usr/sbin/sshd",
            "/bin/bash",
            "/usr/bin/ssh",
            "/private/var/lib/apt",
            "/private/var/lib/cydia",
            "/private/var/stash"
        ]
        
        for path in jbPaths {
            if FileManager.default.fileExists(atPath: path) {
                return .jailbreak
            }
        }
        
        // Check for write access to system directories
        let testPaths = [
            "/var/mobile",
            "/var/mobile/Containers"
        ]
        
        for path in testPaths {
            if FileManager.default.isWritableFile(atPath: path) {
                return .extended
            }
        }
        
        return .sandboxOnly
    }
    
    func getDeviceInfo() -> DeviceInfo {
        let device = UIDevice.current
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        let jbType: String?
        switch currentAccessLevel() {
        case .jailbreak:
            jbType = "Detected"
        case .extended:
            jbType = "Partial"
        case .sandboxOnly:
            jbType = nil
        }
        
        return DeviceInfo(
            iosVersion: device.systemVersion,
            deviceModel: identifier,
            architecture: ProcessInfo.processInfo.isiOSAppOnMac ? "x86_64" : "arm64",
            jailbreakType: jbType
        )
    }
    
    func checkPermission(for path: URL) -> Bool {
        let fm = FileManager.default
        
        // Check if path exists
        guard fm.fileExists(atPath: path.path) else {
            return false
        }
        
        // Check if writable
        return fm.isWritableFile(atPath: path.path)
    }
    
    func getDiagnosticInfo() -> [String: String] {
        var info: [String: String] = [:]
        
        info["iOS Version"] = UIDevice.current.systemVersion
        info["Device Model"] = getDeviceInfo().deviceModel
        info["Architecture"] = getDeviceInfo().architecture
        info["Jailbreak Status"] = isJailbreakAvailable() ? "Available" : "Not Available"
        info["Access Level"] = currentAccessLevel().rawValue
        
        let testPaths = [
            "/var/mobile": "Mobile Directory",
            "/var/mobile/Containers": "Containers",
            "/private/var/mobile": "Private Mobile"
        ]
        
        for (path, name) in testPaths {
            let accessible = FileManager.default.isReadableFile(atPath: path)
            info[name] = accessible ? "OK" : "Restricted"
        }
        
        return info
    }
}
