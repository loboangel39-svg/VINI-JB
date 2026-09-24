import Foundation

class APIClient {
    static let shared = APIClient()
    
    private let baseURL = "https://vini-v2-api.loboangel39.workers.dev"
    private let session: URLSession
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 300
        self.session = URLSession(configuration: config)
    }
    
    func request<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        body: Data? = nil,
        requiresAuth: Bool = true
    ) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw VINIError.networkError("Invalid URL")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = body
        
        if body != nil {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        if requiresAuth {
            guard let token = KeychainManager.shared.loadAuthToken() else {
                throw VINIError.authenticationRequired
            }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw VINIError.networkError("Invalid response")
        }
        
        // Handle token refresh
        if let newToken = httpResponse.value(forHTTPHeaderField: "X-New-Token") {
            KeychainManager.shared.saveAuthToken(newToken)
        }
        
        // Handle 401
        if httpResponse.statusCode == 401 {
            throw VINIError.authenticationRequired
        }
        
        // Handle errors
        guard (200...299).contains(httpResponse.statusCode) else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw VINIError.networkError("HTTP \(httpResponse.statusCode): \(errorMessage)")
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return try decoder.decode(T.self, from: data)
    }
    
    func downloadFile(endpoint: String) async throws -> (Data, [String: String]) {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw VINIError.networkError("Invalid URL")
        }
        
        var request = URLRequest(url: url)
        
        guard let token = KeychainManager.shared.loadAuthToken() else {
            throw VINIError.authenticationRequired
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw VINIError.networkError("Invalid response")
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw VINIError.networkError("HTTP \(httpResponse.statusCode)")
        }
        
        var headers: [String: String] = [:]
        if let version = httpResponse.value(forHTTPHeaderField: "X-Patch-Version") {
            headers["X-Patch-Version"] = version
        }
        if let name = httpResponse.value(forHTTPHeaderField: "X-Patch-Name") {
            headers["X-Patch-Name"] = name
        }
        if let contentKey = httpResponse.value(forHTTPHeaderField: "X-Content-Key") {
            headers["X-Content-Key"] = contentKey
        }
        
        return (data, headers)
    }
}
