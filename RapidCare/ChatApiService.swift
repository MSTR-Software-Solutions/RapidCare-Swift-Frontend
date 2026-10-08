import Foundation

enum APIError: Error, LocalizedError {
    case invalidResponse
    case serverError(statusCode: Int, body: String)
    case decodingFailed(Error)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "The server returned an unexpected response."
        case .serverError(let statusCode, let body):
            return "Server error (\(statusCode)): \(body)"
        case .decodingFailed(let error):
            if let decodingError = error as? DecodingError {
                return Self.describe(decodingError)
            }
            return "Failed to decode response: \(error.localizedDescription)"
        }
    }

    private static func describe(_ error: DecodingError) -> String {
        switch error {
        case .keyNotFound(let key, let context):
            return "Missing field '\(key.stringValue)' at \(context.codingPath.map(\.stringValue).joined(separator: ".")): \(context.debugDescription)"
        case .typeMismatch(let type, let context):
            return "Type mismatch for \(type) at \(context.codingPath.map(\.stringValue).joined(separator: ".")): \(context.debugDescription)"
        case .valueNotFound(let type, let context):
            return "Missing value for \(type) at \(context.codingPath.map(\.stringValue).joined(separator: ".")): \(context.debugDescription)"
        case .dataCorrupted(let context):
            return "Corrupted data at \(context.codingPath.map(\.stringValue).joined(separator: ".")): \(context.debugDescription)"
        @unknown default:
            return "Unknown decoding error: \(error.localizedDescription)"
        }
    }
}

final class ChatAPIService {

    static let shared = ChatAPIService()

    // NOTE: "localhost" only resolves correctly from the iOS Simulator.
    // On a physical device, replace this with your Mac's LAN IP address
    // (e.g. "http://192.168.1.42:8081/rapidCare"), and add an ATS exception
    // in Info.plist since this is plain HTTP, not HTTPS -- see notes below.
    private let baseURL = "http://localhost:8081/rapidCare"

    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    private init() {
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            // Java's LocalDateTime serializes with no timezone and a
            // variable number of fractional-second digits (0 to 9), which
            // ISO8601DateFormatter doesn't handle directly -- try a few
            // explicit formats before giving up.
            let formats = [
                "yyyy-MM-dd'T'HH:mm:ss.SSSSSS",
                "yyyy-MM-dd'T'HH:mm:ss.SSS",
                "yyyy-MM-dd'T'HH:mm:ss"
            ]
            for format in formats {
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "en_US_POSIX")
                formatter.timeZone = TimeZone(identifier: "UTC")
                formatter.dateFormat = format
                if let date = formatter.date(from: dateString) {
                    return date
                }
            }
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unrecognized date format: \(dateString)"
            )
        }

        encoder = JSONEncoder()
    }

    // MARK: - Chat sessions

    func startSession(userId: Int, title: String? = nil) async throws -> ChatSession {
        let request = StartChatSessionRequest(userId: userId, title: title)
        return try await post(path: "/api/chat-sessions", body: request)
    }

    func endSession(sessionId: Int) async throws -> ChatSession {
        return try await post(path: "/api/chat-sessions/\(sessionId)/end", body: Optional<String>.none)
    }

    func getSession(sessionId: Int) async throws -> ChatSession {
        return try await get(path: "/api/chat-sessions/\(sessionId)")
    }

    func getSessionsForUser(userId: Int) async throws -> [ChatSession] {
        return try await get(path: "/api/chat-sessions/user/\(userId)")
    }

    // MARK: - Chat messages

    func getMessages(sessionId: Int) async throws -> [ChatMessage] {
        return try await get(path: "/api/chat-sessions/\(sessionId)/messages")
    }

    // Sends the user's message and returns the bot's reply
    func sendMessage(sessionId: Int, content: String) async throws -> ChatMessage {
        let request = SendChatMessageRequest(content: content)
        return try await post(path: "/api/chat-sessions/\(sessionId)/messages", body: request)
    }

    // MARK: - Generic request helpers

    private func get<Response: Decodable>(path: String) async throws -> Response {
        guard let url = URL(string: baseURL + path) else {
            throw APIError.invalidResponse
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        return try handle(data: data, response: response)
    }

    private func post<Body: Encodable, Response: Decodable>(path: String, body: Body?) async throws -> Response {
        guard let url = URL(string: baseURL + path) else {
            throw APIError.invalidResponse
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let body = body {
            urlRequest.httpBody = try encoder.encode(body)
        }

        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        return try handle(data: data, response: response)
    }

    private func handle<Response: Decodable>(data: Data, response: URLResponse) throws -> Response {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw APIError.serverError(statusCode: httpResponse.statusCode, body: body)
        }

        #if DEBUG
        if let rawJSON = String(data: data, encoding: .utf8) {
            print("[ChatAPIService] Raw response: \(rawJSON)")
        }
        #endif

        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            throw APIError.decodingFailed(error)
        }
    }
}
