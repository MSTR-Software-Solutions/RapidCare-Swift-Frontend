import Foundation
import Combine

@MainActor
final class ChatViewModel: ObservableObject {

    @Published var session: ChatSession?
        @Published var messages: [ChatMessage] = []
        @Published var pastSessions: [ChatSession] = []
        @Published var isSending: Bool = false
        @Published var isLoadingHistory: Bool = false
        @Published var errorMessage: String?

    // Set the user ID for this chat session
    var userId: Int = 1

    private let api = ChatAPIService.shared
    private var nextPlaceholderId = -1
    
    // MARK: - History & Session Switching

    func fetchPastSessions() async {
        isLoadingHistory = true
        defer { isLoadingHistory = false }

        do {
            pastSessions = try await api.getSessionsForUser(userId: userId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func selectSession(_ targetSession: ChatSession) async {
            self.session = targetSession
            self.errorMessage = nil

            // Fetch complete message history for the selected session
            do {
                let loadedMessages = try await api.getMessages(sessionId: targetSession.chatSessionID)
                self.messages = loadedMessages
            } catch {
                // Fall back to messages embedded in the session object if available
                self.messages = targetSession.messages
                self.errorMessage = error.localizedDescription
            }
        }

    // MARK: - Message Handling (Lazy Session Start)

    func sendMessage(_ content: String) async {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !isSending else { return }

        isSending = true
        errorMessage = nil
        defer { isSending = false }

        // 1. Optimistic UI update: show user's bubble immediately
        let optimisticUserMessage = ChatMessage(
            messageID: nextPlaceholderId,
            messageSender: .user,
            content: trimmed,
            sentAt: Date()
        )
        nextPlaceholderId -= 1
        messages.append(optimisticUserMessage)

        do {
            // 2. Lazy Initialization: establish session only when first message is sent
            let targetSessionId: Int
            if let existing = session {
                targetSessionId = existing.chatSessionID
            } else {
                // Dynamically title the session using the first few words
                let previewTitle = String(trimmed.prefix(30))
                let newSession = try await api.startSession(
                    userId: userId,
                    title: previewTitle.isEmpty ? "Assistant Session" : previewTitle
                )
                self.session = newSession
                targetSessionId = newSession.chatSessionID
            }

            // 3. Dispatch message to the backend
            let botReply = try await api.sendMessage(sessionId: targetSessionId, content: trimmed)
            messages.append(botReply)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Session Lifecycle

    /// Clears local state and prepares a fresh uncommitted chat (mimics "New Chat")
    func newChat() {
        session = nil
        messages.removeAll()
        errorMessage = nil
    }

    func endSession() async {
        guard let sessionId = session?.chatSessionID else {
            newChat()
            return
        }
        do {
            session = try await api.endSession(sessionId: sessionId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func refreshMessages() async {
        guard let sessionId = session?.chatSessionID else { return }
        do {
            messages = try await api.getMessages(sessionId: sessionId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
