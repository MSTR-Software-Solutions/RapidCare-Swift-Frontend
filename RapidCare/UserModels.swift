//
//  UserModels.swift
//  RapidCare
//
//  Created by Scelo Kevin on 2026/10/07.
//

import Foundation

// MARK: - User Type (Dropdown Options)

enum AppUserType: String, CaseIterable, Codable, Identifiable {
    case user = "USER"
    case paramedic = "PARAMEDIC"
    case operatorRole = "OPERATOR"
    case admin = "ADMIN"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .user: return "Regular User"
        case .paramedic: return "Paramedic / First Responder"
        case .operatorRole: return "Emergency Operator"
        case .admin: return "System Administrator"
        }
    }
}

// MARK: - User Account Model

struct UserAccount: Codable, Identifiable {
    let userId: Int
    let userName: String
    let userSurname: String
    let email: String
    let phone: String?
    let userType: String

    var id: Int { userId }
    var fullName: String { "\(userName) \(userSurname)" }

    /// Logic: Only Administrators (or Operators) can create an emergency dispatch case
    var canCreateEmergencyCase: Bool {
        let type = userType.uppercased()
        return type == "ADMIN" || type == "OPERATOR"
    }
}

// MARK: - Registration Request DTO (Matches RequestRegistration.java)

struct RegistrationRequest: Codable {
    let userName: String
    let userSurname: String
    let email: String
    let password: String
    let userType: String
}
