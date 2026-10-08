//
//  EmergencyStatus.swift
//  RapidCare
//
//  Created by Scelo Kevin on 2026/10/06.
//
import Foundation

// MARK: - Status Enum

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

// MARK: - Create Case Request DTO

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
    let contactNumber: String?
}

// MARK: - Emergency Case Entity

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
    let caseCreated: Date?
    let user: ChatUser?

    var id: Int { caseId }
    var createdAt: Date? { caseCreated }
    var contactNumber: String? { user?.phone }

    // MARK: - UI Display Helpers
    var displayTitle: String {
        caseName ?? "Case #\(caseId)"
    }

    var displayEmergencyType: String {
        medicalEmergencyType ?? incidentType ?? "Medical Emergency"
    }

    var displayDescription: String {
        incidentDescription ?? "No description provided."
    }

    var displayStatus: String {
        transitStatus ?? "PENDING"
    }

    // MARK: - Codable Keys with Fallbacks
    enum CodingKeys: String, CodingKey {
        case caseID
        case caseId
        case id
        case case_id
        case caseName
        case incidentType
        case medicalEmergencyType
        case incidentDescription
        case transitStatus
        case severityLevel
        case location
        case latitude
        case longitude
        case caseCreated
        case createdAt
        case user
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Decode caseID / caseId
        if let cid = try container.decodeIfPresent(Int.self, forKey: .caseID) {
            self.caseId = cid
        } else if let cid = try container.decodeIfPresent(Int.self, forKey: .caseId) {
            self.caseId = cid
        } else if let idVal = try container.decodeIfPresent(Int.self, forKey: .id) {
            self.caseId = idVal
        } else if let snakeId = try container.decodeIfPresent(Int.self, forKey: .case_id) {
            self.caseId = snakeId
        } else {
            throw DecodingError.keyNotFound(
                CodingKeys.caseID,
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "No 'caseID', 'caseId', or 'id' found in payload.")
            )
        }

        self.caseName = try container.decodeIfPresent(String.self, forKey: .caseName)
        self.incidentType = try container.decodeIfPresent(String.self, forKey: .incidentType)
        self.medicalEmergencyType = try container.decodeIfPresent(String.self, forKey: .medicalEmergencyType)
        self.incidentDescription = try container.decodeIfPresent(String.self, forKey: .incidentDescription)
        self.transitStatus = try container.decodeIfPresent(String.self, forKey: .transitStatus)
        self.severityLevel = try container.decodeIfPresent(String.self, forKey: .severityLevel)
        self.location = try container.decodeIfPresent(String.self, forKey: .location)
        self.latitude = try container.decodeIfPresent(Double.self, forKey: .latitude)
        self.longitude = try container.decodeIfPresent(Double.self, forKey: .longitude)
        self.user = try container.decodeIfPresent(ChatUser.self, forKey: .user)

        // Decode caseCreated / createdAt
        if let createdDate = try container.decodeIfPresent(Date.self, forKey: .caseCreated) {
            self.caseCreated = createdDate
        } else if let createdDate = try container.decodeIfPresent(Date.self, forKey: .createdAt) {
            self.caseCreated = createdDate
        } else {
            self.caseCreated = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(caseId, forKey: .caseID)
        try container.encodeIfPresent(caseName, forKey: .caseName)
        try container.encodeIfPresent(incidentType, forKey: .incidentType)
        try container.encodeIfPresent(medicalEmergencyType, forKey: .medicalEmergencyType)
        try container.encodeIfPresent(incidentDescription, forKey: .incidentDescription)
        try container.encodeIfPresent(transitStatus, forKey: .transitStatus)
        try container.encodeIfPresent(severityLevel, forKey: .severityLevel)
        try container.encodeIfPresent(location, forKey: .location)
        try container.encodeIfPresent(latitude, forKey: .latitude)
        try container.encodeIfPresent(longitude, forKey: .longitude)
        try container.encodeIfPresent(caseCreated, forKey: .caseCreated)
        try container.encodeIfPresent(user, forKey: .user)
    }
}
