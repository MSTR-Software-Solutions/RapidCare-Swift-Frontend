//
//  ChatRequests.swift
//  
//
//  Created by Scelo Kevin on 2026/07/19.
//

import Foundation

struct StartChatSessionRequest: Codable {
    let userId: Int
    let title: String?
}

struct SendChatMessageRequest: Codable {
    let content: String
}
