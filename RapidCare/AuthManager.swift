//
//  AuthManager.swift
//  RapidCare
//
//  Created by Scelo Kevin on 2026/10/07.
//


import Foundation
import Combine

@MainActor
final class AuthManager: ObservableObject {
    @Published var currentUser: UserAccount?
    @Published var isLoading: Bool = false
    @Published var authError: String?

    private let api = UserAPIService.shared
    private let userDefaultsKey = "savedRapidCareUser"

    init() {
        // Restore existing user session if available
        if let savedData = UserDefaults.standard.data(forKey: userDefaultsKey),
           let user = try? JSONDecoder().decode(UserAccount.self, from: savedData) {
            self.currentUser = user
        }
    }

    func login(email: String, password: String) async -> Bool {
        guard !email.isEmpty, !password.isEmpty else {
            authError = "Please enter both email and password."
            return false
        }

        isLoading = true
        authError = nil
        defer { isLoading = false }

        do {
            let user = try await api.login(email: email, password: password)
            saveUser(user)
            return true
        } catch {
            authError = error.localizedDescription
            return false
        }
    }

    func register(name: String, surname: String, email: String, password: String, type: AppUserType) async -> Bool {
        guard !name.isEmpty, !surname.isEmpty, !email.isEmpty, !password.isEmpty else {
            authError = "Please complete all required fields."
            return false
        }

        isLoading = true
        authError = nil
        defer { isLoading = false }

        let request = RegistrationRequest(
            userName: name,
            userSurname: surname,
            email: email,
            password: password,
            userType: type.rawValue
        )

        do {
            let user = try await api.registerUser(request: request)
            saveUser(user)
            return true
        } catch {
            authError = error.localizedDescription
            return false
        }
    }

    func logout() {
        currentUser = nil
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }

    private func saveUser(_ user: UserAccount) {
        self.currentUser = user
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
}