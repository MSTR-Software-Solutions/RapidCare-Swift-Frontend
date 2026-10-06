//
//  ChatHistoryDrawer.swift
//  RapidCare
//
//  Created by Scelo Kevin on 2026/10/06.
//

import SwiftUI

struct ChatHistoryDrawer: View {
    @ObservedObject var viewModel: ChatViewModel
    @Binding var isOpen: Bool

    // Tracks swipe-to-dismiss offset
    @GestureState private var dragOffset: CGFloat = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // MARK: - Drawer Header
            HStack {
                Text("Chat History")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(RapidCareColor.onyx)
                Spacer()
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        isOpen = false
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(RapidCareColor.onyx.opacity(0.4))
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 24)
            .padding(.bottom, 14)

            // MARK: - "New Chat" Quick Action
            Button {
                withAnimation {
                    viewModel.newChat()
                    isOpen = false
                }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "plus.bubble.fill")
                        .font(.headline)
                    Text("New Chat")
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(RapidCareColor.cerulean)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.pressable)
            .padding(.horizontal, 16)
            .padding(.bottom, 14)

            Divider()

            // MARK: - Conversations List
            if viewModel.isLoadingHistory {
                VStack {
                    Spacer()
                    ProgressView("Loading conversations...")
                        .font(.footnote)
                        .foregroundStyle(RapidCareColor.onyx.opacity(0.6))
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.pastSessions.isEmpty {
                VStack(spacing: 10) {
                    Spacer()
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 38))
                        .foregroundStyle(RapidCareColor.onyx.opacity(0.25))
                    Text("No past conversations")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(RapidCareColor.onyx.opacity(0.5))
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 6) {
                        ForEach(viewModel.pastSessions) { item in
                            sessionRow(item)
                        }
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                }
                .frame(maxHeight: .infinity)
            }
        }
        .frame(width: 300)
        .frame(maxHeight: .infinity) // Ensures drawer stretches edge-to-edge vertically
        .background(Color.white)
        .overlay(
            Rectangle()
                .frame(width: 1)
                .foregroundStyle(Color.black.opacity(0.06)),
            alignment: .trailing
        )
        .offset(x: min(0, dragOffset))
        .gesture(
            DragGesture()
                .updating($dragOffset) { value, state, _ in
                    if value.translation.width < 0 {
                        state = value.translation.width
                    }
                }
                .onEnded { value in
                    if value.translation.width < -80 {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            isOpen = false
                        }
                    }
                }
        )
    }

    // MARK: - Row Item
    private func sessionRow(_ item: ChatSession) -> some View {
        let isSelected = viewModel.session?.chatSessionID == item.chatSessionID

        return Button {
            Task {
                await viewModel.selectSession(item)
                withAnimation {
                    isOpen = false
                }
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? "bubble.left.fill" : "bubble.left")
                    .font(.caption)
                    .foregroundStyle(isSelected ? RapidCareColor.cerulean : RapidCareColor.onyx.opacity(0.45))

                VStack(alignment: .leading, spacing: 3) {
                    Text(item.title ?? "Untitled Conversation")
                        .font(.subheadline.weight(isSelected ? .semibold : .regular))
                        .foregroundStyle(RapidCareColor.onyx)
                        .lineLimit(1)

                    Text(formattedDate(item.startedAt))
                        .font(.caption2)
                        .foregroundStyle(RapidCareColor.onyx.opacity(0.45))
                }
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(isSelected ? RapidCareColor.cerulean.opacity(0.12) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }

    private func formattedDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            return date.formatted(date: .abbreviated, time: .omitted)
        }
    }
}
