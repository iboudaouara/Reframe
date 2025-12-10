import Foundation

struct AppURL: Sendable{
    static let serverURL = "https://ibrahimboudaouara.com/reframe"
    
    static let privacyPolicy = "\(serverURL)/privacy"
    static let termsOfUse = "\(serverURL)/terms-of-use"
    static let authURL = "\(serverURL)/api/auth"
    static let insightURL = "\(serverURL)/api/insights"
}

struct InsightResponse: Decodable {
    let reply: String?
    let error: String?
}

struct ServerErrorResponse: Decodable {
    let error: String
}

enum ServerError: Error, LocalizedError {
    case httpError(statusCode: Int, message: String)
    
    var errorDescription: String? {
        switch self {
        case .httpError(let statusCode, let message):
            return "Erreur HTTP \(statusCode): \(message)"
        }
    }
}

final class ReframeServer {
    
    private let serverURL = URL(string: AppURL.serverURL)!
    static let shared = ReframeServer()
    
    func generateInsight(from input: String) async throws -> InsightResponse {
        var request = URLRequest(url: serverURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["input": input]
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        // ... (gestion du guard let httpResp) ...
        
        print("SERVER RESPONSE RAW:", String(data: data, encoding: .utf8) ?? "nil")
        
        // 🎯 CORRECTION: Effectuer le décodage de manière non-isolée (sur un acteur générique).
        let decodedResponse = try JSONDecoder().decode(InsightResponse.self, from: data)
        
        return decodedResponse
    }
    
    private let baseURL = AppURL.authURL
    
    func request<T: Decodable>(
        endpoint: String,
        method: String,
        headers: [String: String] = [:],
        body: (any Encodable)? = nil,
        urlBase: String? = nil// 🆕 Nouveau paramètre par défaut (pour la rétrocompatibilité)
    ) async throws -> T {
        
        let finalURLBase = urlBase ?? AppURL.authURL
        
        // 3. Utiliser finalURLBase pour la construction de l'URL
        let fullPath = endpoint.isEmpty ? finalURLBase : "\(finalURLBase)/\(endpoint)"
        guard let url = URL(string: fullPath) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        headers.forEach { key, value in
            request.addValue(value, forHTTPHeaderField: key)
        }
        
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResp = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if !(200...299).contains(httpResp.statusCode) {
            print("SERVER ERROR RAW:", String(data: data, encoding: .utf8) ?? "nil")
            
            let serverError = try? JSONDecoder().decode(ServerErrorResponse.self, from: data)
            throw ServerError
                .httpError(
                    statusCode: httpResp.statusCode,
                    message: serverError?.error ?? "Une erreur est survenue sur le serveur."
                )
        }
        
        // 💡 Assurez-vous que votre JSONDecoder est configuré pour décoder les dates PostgreSQL si nécessaire.
        // Par exemple: JSONDecoder().dateDecodingStrategy = .iso8601
        
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    // InsightModels.swift (ou dans ReframeServer.swift)
    
    // Le corps de la requête POST pour sauvegarder un insight
    struct SaveInsightRequest: Encodable {
        let userThought: String
        let generatedInsight: String
        let openaiToken: String? // Optionnel
        
        enum CodingKeys: String, CodingKey {
            case userThought
            case generatedInsight
            case openaiToken
        }
    }
    
    // La structure de la réponse du serveur pour un insight (pour GET et POST)
    struct RemoteInsight: Decodable {
        let id: Int
        let user_id: Int
        let user_thought: String
        let generated_insight: String
        let created_at: Date
        
        var localInsight: Insight {
                    // Assurez-vous que le type Insight est accessible.
                    // Si non, vous pourriez avoir besoin d'importer SwiftData ou le module InsightController
                    return Insight(
                        userThought: user_thought,
                        generatedInsight: generated_insight,
                        timestamp: created_at,
                        serverId: id,
                        syncStatus: .synced
                    )
                }

        // Le champ 'openai_token' est omis s'il n'est pas nécessaire sur le client
        
        enum CodingKeys: String, CodingKey {
            case id
            case user_id
            case user_thought
            case generated_insight
            case created_at
        }
    }
    
    // La structure de la réponse du serveur pour la suppression (DELETE)
    struct DeleteInsightResponse: Decodable {
        let message: String
        let id: String // Ou Int, selon ce que le serveur retourne
    }
    
    
    // Fichier: ReframeServer.swift
    
    // ... (votre code existant) ...
    
    // Base URL pour les insights (à ajouter à AppURL si vous l'utilisez)
    
    // J'assume que la route sera /api/insights
    
    // Nouvelle fonction pour sauvegarder un insight
    func saveInsight(thought: String, insight: String, token: String, openaiToken: String? = nil) async throws -> RemoteInsight {
        let headers = ["Authorization": "Bearer \(token)"]
        let body = SaveInsightRequest(userThought: thought, generatedInsight: insight, openaiToken: openaiToken)
        
        return try await request(
            endpoint: "", // On laisse vide pour utiliser l'URL de base /api/insights
            method: "POST",
            headers: headers,
            body: body,
            urlBase: AppURL.insightURL // Surcharge de la base d'URL
        )
    }
    
    func fetchUserInsights(token: String) async throws -> [RemoteInsight] {
        let headers = ["Authorization": "Bearer \(token)"]
        
        return try await request(
            endpoint: "", // On laisse vide pour utiliser l'URL de base /api/insights
            method: "GET",
            headers: headers,
            urlBase: AppURL.insightURL // Surcharge de la base d'URL
        )
    }
    
    // 🔄 CORRECTION : id est maintenant un Int et est inclus correctement dans l'endpoint
    func deleteInsight(id: Int, token: String) async throws -> DeleteInsightResponse {
        let headers = ["Authorization": "Bearer \(token)"]
        
        return try await request(
            endpoint: "\(id)", // ✅ L'ID est passé comme segment d'endpoint.
            method: "DELETE",
            headers: headers,
            urlBase: AppURL.insightURL // Surcharge de la base d'URL
        )
    }
}

