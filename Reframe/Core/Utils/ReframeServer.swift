import Foundation

struct AppURL {
    static let serverURL = "https://ibrahimboudaouara.com/reframe"

    static let privacyPolicy = "\(serverURL)/privacy"
    static let termsOfUse = "\(serverURL)/terms-of-use"
    static let authURL = "\(serverURL)/api/auth"
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

        let (data, response) = try await URLSession.shared.data(for: request)

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
        body: (any Encodable)? = nil
    ) async throws -> T {

        guard let url = URL(string: "\(baseURL)/\(endpoint)") else {
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

        return try JSONDecoder().decode(T.self, from: data)
    }
}

