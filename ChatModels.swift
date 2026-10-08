import Foundation

// MARK: - Enums (must match the exact string values Java's enums serialize to)

enum MessageSender: String, Codable {
    case user = "USER"
    case bot = "RAPIDCARE"
}

enum ChatSessionStatus: String, Codable {
    case active = "ACTIVE"
    case ended = "ENDED"
}

// MARK: - Nested User (subset actually exposed by the backend)

struct ChatUser: Codable, Identifiable {
    let userId: Int
    let userName: String
    let userSurname: String
    let email: String
    let phone: String?
    let userType: String
    // medicalInformation omitted here -- add its own Codable struct
    // once you need those fields on the Swift side.

    var id: Int { userId }
}

// MARK: - ChatMessage

struct ChatMessage: Codable, Identifiable {
    let messageID: Int
    let messageSender: MessageSender
    let content: String
    let sentAt: Date

    var id: Int { messageID }
}

// MARK: - ChatSession

struct ChatSession: Codable, Identifiable {
    let chatSessionID: Int
    let user: ChatUser
    let title: String?
    let startedAt: Date
    let endedAt: Date?
    let status: ChatSessionStatus
    let messages: [ChatMessage]

    var id: Int { chatSessionID }
}
