import SwiftUI

struct AppURL: Sendable{
    static let serverURL = "https://ibrahimboudaouara.com/reframe"
    
    static let privacyPolicy = "\(serverURL)/privacy"
    static let termsOfUse = "\(serverURL)/terms-of-use"
    static let authURL = "\(serverURL)/api/auth"
    static let insightURL = "\(serverURL)/api/insights"
    static let tacticalURL = "\(serverURL)/api/tactical"
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
    
    var errorDescription: LocalizedStringKey? {
        switch self {
        case .httpError(let statusCode, let message):
            return "HTTP Error \(statusCode): \(message)"
        }
    }
}

final class ReframeServer {
    
    private let serverURL = URL(string: AppURL.serverURL)!
    static let shared = ReframeServer()

    func handleAuthError(_ statusCode: Int) async {
        if statusCode == 401 {
            await MainActor.run {
                KeychainManager.shared.deleteToken()
                NotificationCenter.default.post(name: .userSessionExpired, object: nil)
            }
        }
    }

    func generateInsight(from input: String) async throws -> InsightResponse {
        var request = URLRequest(url: serverURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["input": input]
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        print("SERVER RESPONSE RAW:", String(data: data, encoding: .utf8) ?? "nil")
        
        let decodedResponse = try JSONDecoder().decode(InsightResponse.self, from: data)
        
        return decodedResponse
    }
    
    private let baseURL = AppURL.authURL
    /*
    func request<T: Decodable>(
        endpoint: String,
        method: String,
        headers: [String: String] = [:],
        body: (any Encodable)? = nil,
        urlBase: String? = nil
    ) async throws -> T {
        
        let finalURLBase = urlBase ?? AppURL.authURL
        
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

        if let httpResponse = response as? HTTPURLResponse {
            print("📢 [SERVER] Status Code reçu : \(httpResponse.statusCode)") // <--- C'est lui qui te dira si c'est 404 ou 500
        }
        
        guard let httpResp = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        if httpResp.statusCode == 401 {
            await handleAuthError(401)
            throw ServerError.httpError(statusCode: 401, message: "Session expired. Please log in again.")
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
        
        return try JSONDecoder().decode(T.self, from: data)
    }*/
    func request<T: Decodable>(
            endpoint: String,
            method: String,
            headers: [String: String] = [:],
            body: (any Encodable)? = nil,
            urlBase: String? = nil
        ) async throws -> T {

            let finalURLBase = urlBase ?? AppURL.authURL

            let fullPath = endpoint.isEmpty ? finalURLBase : "\(finalURLBase)/\(endpoint)"
            guard let url = URL(string: fullPath) else {
                throw URLError(.badURL)
            }

            var request = URLRequest(url: url)
            request.httpMethod = method
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")

            // 1. D'abord on ajoute les headers spécifiques passés en paramètre
            headers.forEach { key, value in
                request.addValue(value, forHTTPHeaderField: key)
            }

            // 👇 AJOUT CRITIQUE (ARCHITECTURE OPEN/CLOSED) 👇
            // Si aucun header "Authorization" n'a été fourni manuellement,
            // on demande au KeychainManager si un token est disponible.
            if request.value(forHTTPHeaderField: "Authorization") == nil {
                if let token = KeychainManager.shared.getToken() {
                    request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                    // print("🔑 [ReframeServer] Token injecté automatiquement depuis le Keychain")
                }
            }
            // 👆 FIN DE L'AJOUT 👆

            if let body = body {
                request.httpBody = try JSONEncoder().encode(body)
            }

            let (data, response) = try await URLSession.shared.data(for: request)

            // ... Le reste de ta fonction reste identique ...
            if let httpResponse = response as? HTTPURLResponse {
                 // print("📢 [SERVER] Status Code reçu : \(httpResponse.statusCode)")
            }

            guard let httpResp = response as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }

            if httpResp.statusCode == 401 {
                await handleAuthError(401)
                throw ServerError.httpError(statusCode: 401, message: "Session expired. Please log in again.")
            }

            if !(200...299).contains(httpResp.statusCode) {
                // print("SERVER ERROR RAW:", String(data: data, encoding: .utf8) ?? "nil")

                let serverError = try? JSONDecoder().decode(ServerErrorResponse.self, from: data)
                throw ServerError
                    .httpError(
                        statusCode: httpResp.statusCode,
                        message: serverError?.error ?? "Une erreur est survenue sur le serveur."
                    )
            }

            return try JSONDecoder().decode(T.self, from: data)
        }

    struct SaveInsightRequest: Encodable {
        let userThought: String
        let generatedInsight: String
        let openaiToken: String?
    }
    
    struct RemoteInsight: Decodable {
        let id: Int
        let user_id: Int
        let user_thought: String
        let generated_insight: String
        let created_at: Date
        
        var localInsight: Insight {
            return Insight(
                userThought: user_thought,
                generatedInsight: generated_insight,
                timestamp: created_at,
                serverId: id,
                syncStatus: .synced
            )
        }

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
    

    func saveInsight(thought: String, insight: String, token: String, openaiToken: String? = nil) async throws -> RemoteInsight {
        let _ = ["Authorization": "Bearer \(token)"]
        let _ = openaiToken ?? "default-openai-token"
        // ✅ La structure utilise maintenant les bons noms de propriétés
        let body = SaveInsightRequest(
            userThought: thought,
            generatedInsight: insight,
            openaiToken: "openaiToken"
        )

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let fullPath = AppURL.insightURL
        guard let url = URL(string: fullPath) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        request.httpBody = try JSONEncoder().encode(body)

        // Debug: Afficher la requête
        if let bodyData = request.httpBody,
           let bodyString = String(data: bodyData, encoding: .utf8) {
            print("📤 REQUEST BODY:", bodyString)
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResp = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        // Debug: Afficher la réponse
        print("📥 RESPONSE STATUS:", httpResp.statusCode)
        print("📥 RESPONSE BODY:", String(data: data, encoding: .utf8) ?? "nil")

        if !(200...299).contains(httpResp.statusCode) {
            let serverError = try? decoder.decode(ServerErrorResponse.self, from: data)
            throw ServerError.httpError(
                statusCode: httpResp.statusCode,
                message: serverError?.error ?? "Une erreur est survenue sur le serveur."
            )
        }

        return try decoder.decode(RemoteInsight.self, from: data)
    }

    func fetchUserInsights(token: String) async throws -> [RemoteInsight] {
        let _ = ["Authorization": "Bearer \(token)"]

        // ✅ Configuration du décodeur pour gérer les dates ISO8601
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let fullPath = AppURL.insightURL
        guard let url = URL(string: fullPath) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResp = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        if !(200...299).contains(httpResp.statusCode) {
            let serverError = try? decoder.decode(ServerErrorResponse.self, from: data)
            throw ServerError.httpError(
                statusCode: httpResp.statusCode,
                message: serverError?.error ?? "Une erreur est survenue sur le serveur."
            )
        }

        return try decoder.decode([RemoteInsight].self, from: data)
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

// Dans ReframeServer.swift

// Structure pour l'envoi
struct SaveTacticalSessionRequest: Encodable {
    let situation: String
    let maneuverName: String
    let maneuverDescription: String
    let powerScore: Int
    let emotionalImpact: String
    let timestamp: Date
}

// Structure de réponse pour la sauvegarde
struct SaveSessionResponse: Decodable {
    let id: Int
}

extension ReframeServer {

    // 1. Sauvegarder une session
    func saveTacticalSession(_ session: TacticalSession, token: String) async throws -> Int {
        let body = SaveTacticalSessionRequest(
            situation: session.situation,
            maneuverName: session.maneuverName,
            maneuverDescription: session.maneuverDescription,
            powerScore: session.powerScore,
            emotionalImpact: session.emotionalImpact,
            timestamp: session.timestamp
        )

        // On suppose que l'endpoint est /api/tactical/sessions
        let response: SaveSessionResponse = try await request(
            endpoint: "sessions",
            method: "POST",
            body: body,
            urlBase: AppURL.tacticalURL
        )
        return response.id
    }

    // 2. Récupérer l'historique
    func fetchTacticalHistory(token: String) async throws -> [TacticalService.RemoteTacticalSession] {
        return try await request(
            endpoint: "history",
            method: "GET",
            urlBase: AppURL.tacticalURL
        )
    }
}

