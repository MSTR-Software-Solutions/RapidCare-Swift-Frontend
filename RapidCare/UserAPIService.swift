//
//  UserAPIService.swift
//  RapidCare
//
//  Created by Scelo Kevin on 2026/10/07.
//


import Foundation

final class UserAPIService {
    static let shared = UserAPIService()

    private let baseURL = "http://localhost:8081/rapidCare"
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    private init() {}

    // POST /api/users/register
    func registerUser(request: RegistrationRequest) async throws -> UserAccount {
        return try await post(path: "/api/users/register", body: request)
    }

    // Login: Validates against registered users
    func login(email: String, password: String) async throws -> UserAccount {
        let allUsers: [UserAccount] = try await get(path: "/api/users")
        guard let user = allUsers.first(where: { $0.email.lowercased() == email.lowercased() }) else {
            throw APIError.serverError(statusCode: 401, body: "Invalid email or user not found.")
        }
        return user
    }

    // GET /api/users/{id}
    func getUser(id: Int) async throws -> UserAccount {
        return try await get(path: "/api/users/\(id)")
    }

    // MARK: - Networking
    private func get<Response: Decodable>(path: String) async throws -> Response {
        guard let url = URL(string: baseURL + path) else { throw APIError.invalidResponse }
        let (data, response) = try await URLSession.shared.data(from: url)
        return try handle(data: data, response: response)
    }

    private func post<Body: Encodable, Response: Decodable>(path: String, body: Body) async throws -> Response {
        guard let url = URL(string: baseURL + path) else { throw APIError.invalidResponse }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)
        return try handle(data: data, response: response)
    }

    private func handle<Response: Decodable>(data: Data, response: URLResponse) throws -> Response {
        guard let httpResponse = response as? HTTPURLResponse else { throw APIError.invalidResponse }
        guard (200...299).contains(httpResponse.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw APIError.serverError(statusCode: httpResponse.statusCode, body: body)
        }
        return try decoder.decode(Response.self, from: data)
    }
}