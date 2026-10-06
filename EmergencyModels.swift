//
//  EmergencyModels.swift
//  RapidCare
//
//  Created by Scelo Kevin on 2026/09/05.
//

import Foundation

// Matches Java Enums exactly
enum IncidentType: String, CaseIterable, Codable, Identifiable {
    case medicalEmergency = "MEDICAL_EMERGENCY"
    case trafficAccident = "TRAFFIC_ACCIDENT"
    case fire = "FIRE"
    case crime = "CRIME"
    case other = "OTHER"
    
    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .medicalEmergency: return "Medical Emergency"
        case .trafficAccident: return "Traffic Accident"
        case .fire: return "Fire"
        case .crime: return "Crime"
        case .other: return "Other"
        }
    }
}

enum MedicalEmergencyType: String, CaseIterable, Codable, Identifiable {
    case cardiacArrest = "CARDIAC_ARREST"
    case stroke = "STROKE"
    case severeBleeding = "SEVERE_BLEEDING"
    case respiratoryDistress = "RESPIRATORY_DISTRESS"
    case trauma = "TRAUMA"
    case allergicReaction = "ALLERGIC_REACTION"
    case other = "OTHER"
    
    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .cardiacArrest: return "Cardiac Arrest"
        case .stroke: return "Stroke"
        case .severeBleeding: return "Severe Bleeding"
        case .respiratoryDistress: return "Respiratory Distress"
        case .trauma: return "Trauma / Fracture"
        case .allergicReaction: return "Allergic Reaction"
        case .other: return "Other"
        }
    }
}

enum SeverityLevel: String, CaseIterable, Codable, Identifiable {
    case low = "LOW"
    case moderate = "MODERATE"
    case critical = "CRITICAL"
    case lifeThreatening = "LIFE_THREATENING"
    
    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .low: return "Low"
        case .moderate: return "Moderate"
        case .critical: return "Critical"
        case .lifeThreatening: return "Life Threatening"
        }
    }
}

// Matches CreateEmergencyCaseRequest.java
struct CreateEmergencyCaseRequest: Codable {
    let userId: Int
    let location: String
    let latitude: Double
    let longitude: Double
    let incidentType: IncidentType
    let medicalEmergencyType: MedicalEmergencyType?
    let incidentDescription: String
    let severityLevel: SeverityLevel
}

// Lightweight response representation
struct EmergencyCaseResponse: Codable, Identifiable {
    let caseID: Int
    let location: String
    let latitude: Double
    let longitude: Double
    let incidentType: IncidentType
    let severityLevel: SeverityLevel
    let transitStatus: String?
    
    var id: Int { caseID }
}
