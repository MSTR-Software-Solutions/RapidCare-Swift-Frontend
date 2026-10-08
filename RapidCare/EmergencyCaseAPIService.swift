//
//  EmergencyCaseAPIService.swift
//  RapidCare
//
//  Created by Scelo Kevin on 2026/10/06.
//


import Foundation

final class EmergencyCaseAPIService {
    static let shared = EmergencyCaseAPIService()

    private let baseURL = "http://localhost:8081/rapidCare"
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    private init() {
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
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

    // POST /api/emergency-cases
    func createCase(request: CreateEmergencyCaseRequest) async throws -> EmergencyCase {
        try await post(path: "/api/emergency-cases", body: request)
    }

    // GET /api/emergency-cases/{caseId}
    func getCase(caseId: Int) async throws -> EmergencyCase {
        try await get(path: "/api/emergency-cases/\(caseId)")
    }

    // GET /api/emergency-cases
    func getAllCases() async throws -> [EmergencyCase] {
        try await get(path: "/api/emergency-cases")
    }

    // GET /api/emergency-cases/user/{userId}
    func getCasesForUser(userId: Int) async throws -> [EmergencyCase] {
        try await get(path: "/api/emergency-cases/user/\(userId)")
    }
    
    // GET /api/emergency-cases/case-name/{caseName}
    func getCasesByCaseName(_ caseName: String) async throws -> [EmergencyCase] {
        let trimmed = caseName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let encodedName = trimmed.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            throw APIError.invalidResponse
        }
        return try await get(path: "/api/emergency-cases/case-name/\(encodedName)")
    }

    // MARK: - Networking Helpers
    private func get<Response: Decodable>(path: String) async throws -> Response {
        guard let url = URL(string: baseURL + path) else { throw APIError.invalidResponse }
        let (data, response) = try await URLSession.shared.data(from: url)
        return try handle(data: data, response: response)
    }

    private func post<Body: Encodable, Response: Decodable>(path: String, body: Body) async throws -> Response {
        guard let url = URL(string: baseURL + path) else { throw APIError.invalidResponse }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try encoder.encode(body)

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
            print("[EmergencyCaseAPIService] Raw JSON: \(rawJSON)")
        }
        #endif

        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            throw APIError.decodingFailed(error)
        }
    }
}
