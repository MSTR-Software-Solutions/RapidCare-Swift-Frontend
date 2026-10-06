//
//  EmergencyCaseViewModel.swift
//  RapidCare
//
//  Created by Scelo Kevin on 2026/09/05.
//

import Foundation
import Combine
import CoreLocation

@MainActor
final class EmergencyCaseViewModel: ObservableObject {
    @Published var locationName: String = ""
    @Published var incidentType: IncidentType = .medicalEmergency
    @Published var medicalEmergencyType: MedicalEmergencyType = .respiratoryDistress
    @Published var severityLevel: SeverityLevel = .critical
    @Published var incidentDescription: String = ""
    
    @Published var isSubmitting: Bool = false
    @Published var submittedCase: EmergencyCaseResponse?
    @Published var errorMessage: String?
    
    let locationManager = LocationManager()
    private let api = EmergencyAPIService.shared
    
    var canSubmit: Bool {
        !locationName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !incidentDescription.trimmingCharacters(in: .whitespaces).isEmpty &&
        !isSubmitting
    }
    
    func submitCase(userId: Int) async {
        guard canSubmit else { return }
        isSubmitting = true
        errorMessage = nil
        defer { isSubmitting = false }
        
        let lat = locationManager.location?.coordinate.latitude ?? -29.8587
        let lon = locationManager.location?.coordinate.longitude ?? 31.0218
        
        let req = CreateEmergencyCaseRequest(
            userId: userId,
            location: locationName,
            latitude: lat,
            longitude: lon,
            incidentType: incidentType,
            medicalEmergencyType: incidentType == .medicalEmergency ? medicalEmergencyType : nil,
            incidentDescription: incidentDescription,
            severityLevel: severityLevel
        )
        
        do {
            submittedCase = try await api.createEmergencyCase(request: req)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
