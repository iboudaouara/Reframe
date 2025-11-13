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

        guard let httpResp = response as? HTTPURLResponse,
              httpResp.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        print("SERVER RESPONSE RAW:", String(data: data, encoding: .utf8) ?? "nil")

        return try JSONDecoder().decode(InsightResponse.self, from: data)
    }

    private let baseURL = AppURL.authURL

    func request<T: Decodable>(
        endpoint: String,
        method: String,
        headers: [String: String] = [:],
        body: [String: Any]? = nil,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        guard let url = URL(string: "\(baseURL)/\(endpoint)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        headers.forEach { key, value in
            request.addValue(value, forHTTPHeaderField: key)
        }

        if let body = body {
            do {
                        let jsonData = try JSONSerialization.data(withJSONObject: body, options: [])
                        request.httpBody = jsonData

                        print("===== REQUEST BODY JSON =====")
                        print(String(data: jsonData, encoding: .utf8) ?? "Invalid UTF-8")
                    } catch {
                        print("❌ JSON ENCODING ERROR:", error)
                    }
        } else {
            print("===== NO REQUEST BODY =====")
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                Task { @MainActor in completion(.failure(error)) }
                return
            }

            guard let data = data else {
                Task { @MainActor in
                    completion(.failure(
                        NSError(
                            domain: "",
                            code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "No data returned"]
                        )
                    ))
                }
                return
            }
            print("RAW RESPONSE STRING:")
            print(String(data: data, encoding: .utf8) ?? "nil")

            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                Task { @MainActor in completion(.success(decoded)) }
            } catch {
                Task { @MainActor in completion(.failure(error)) }
            }
        }.resume()
    }


}

