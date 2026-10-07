//
//  EmergencyCaseViewModel.swift
//  RapidCare
//
//  Created by Scelo Kevin on 2026/09/05.
//

import Foundation
import Combine

@MainActor
final class EmergencyCaseViewModel: ObservableObject {
    @Published var userCases: [EmergencyCase] = []
    @Published var activeCase: EmergencyCase?
    @Published var isSubmitting: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    var userId: Int = 1
    private let api = EmergencyCaseAPIService.shared

    // In EmergencyCaseViewModel.swift

    func submitCase(type: String, description: String, location: String? = nil) async -> Bool {
        guard !type.isEmpty, !description.isEmpty else {
            errorMessage = "Please choose an emergency type and provide a description."
            return false
        }

        isSubmitting = true
        errorMessage = nil
        defer { isSubmitting = false }

        let request = CreateEmergencyCaseRequest(
            userId: userId,
            caseName: "Case - \(type)",
            location: location,
            latitude: nil,
            longitude: nil,
            incidentType: "MEDICAL",
            medicalEmergencyType: type,
            incidentDescription: description,
            severityLevel: "HIGH"
        )

        do {
            let newCase = try await api.createCase(request: request)
            self.activeCase = newCase
            self.userCases.insert(newCase, at: 0)
            return true
        } catch {
            self.errorMessage = error.localizedDescription
            return false
        }
    }

    func loadUserCases() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            self.userCases = try await api.getCasesForUser(userId: userId)
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}
