//
//  EmergencyStatus.swift
//  RapidCare
//
//  Created by Scelo Kevin on 2026/10/06.
//


import Foundation

enum EmergencyStatus: String, Codable {
    case pending = "PENDING"
    case dispatched = "DISPATCHED"
    case enRoute = "EN_ROUTE"
    case resolved = "RESOLVED"
    case cancelled = "CANCELLED"
    
    var title: String {
        switch self {
        case .pending: return "Pending Review"
        case .dispatched: return "Ambulance Dispatched"
        case .enRoute: return "En Route"
        case .resolved: return "Resolved"
        case .cancelled: return "Cancelled"
        }
    }
}

struct EmergencyCase: Codable, Identifiable {
    let caseId: Int
    let caseName: String?
    let incidentType: String?
    let medicalEmergencyType: String?
    let incidentDescription: String?
    let transitStatus: String?
    let severityLevel: String?
    let location: String?
    let latitude: Double?
    let longitude: Double?
    let contactNumber: String?
    let createdAt: Date?

    var id: Int { caseId }

    // Display helpers for UI
    var displayTitle: String {
        caseName ?? "Case #\(caseId)"
    }

    var displayEmergencyType: String {
        medicalEmergencyType ?? incidentType ?? "Medical Emergency"
    }

    var displayDescription: String {
        incidentDescription ?? "No additional description provided."
    }

    var displayStatus: String {
        transitStatus ?? "PENDING"
    }
}


struct CreateEmergencyCaseRequest: Codable {
    let userId: Int
    let caseName: String?
    let location: String?
    let latitude: Double?
    let longitude: Double?
    let incidentType: String?
    let medicalEmergencyType: String?
    let incidentDescription: String?
    let severityLevel: String?
}
import Foundation


