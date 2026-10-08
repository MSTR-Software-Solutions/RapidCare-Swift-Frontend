//
//  MessageBubbleView.swift
//  RapidCare
//
//  Created by Scelo Kevin on 2026/07/19.
//

import SwiftUI

/// A single chat bubble, styled per RapidCare's visual spec:
/// outgoing = solid Dark Cyan with Porcelain text, incoming = Porcelain with
/// a thin Cerulean border and Onyx text. No gradients anywhere.
struct MessageBubbleView: View {
    let message: ChatMessage
    /// Upper bound on bubble width, computed by the parent from the
    /// available container width (roughly 75% of the chat view).
    let maxBubbleWidth: CGFloat

    private var isOutgoing: Bool { message.messageSender == .user }

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if isOutgoing { Spacer(minLength: 40) }

            VStack(alignment: isOutgoing ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .font(.body)
                    .foregroundStyle(isOutgoing ? RapidCareColor.porcelain : RapidCareColor.onyx)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(bubbleBackground)
                    .frame(maxWidth: maxBubbleWidth, alignment: isOutgoing ? .trailing : .leading)

                Text(message.sentAt, style: .time)
                    .font(.caption)
                    .foregroundStyle(RapidCareColor.onyx.opacity(0.55))
                    .padding(.horizontal, 4)
            }

            if !isOutgoing { Spacer(minLength: 40) }
        }
        .padding(.horizontal, 4)
        .transition(
            .asymmetric(
                insertion: .move(edge: isOutgoing ? .trailing : .leading).combined(with: .opacity),
                removal: .opacity
            )
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(isOutgoing ? "You" : "RapidCare assistant") said: \(message.content)")
    }

    @ViewBuilder
    private var bubbleBackground: some View {
        RoundedRectangle(cornerRadius: RapidCareMetrics.bubbleCornerRadius, style: .continuous)
            .fill(isOutgoing ? RapidCareColor.darkCyan : RapidCareColor.porcelain)
            .overlay(
                RoundedRectangle(cornerRadius: RapidCareMetrics.bubbleCornerRadius, style: .continuous)
                    .strokeBorder(
                        isOutgoing ? Color.clear : RapidCareColor.cerulean.opacity(0.25),
                        lineWidth: 1
                    )
            )
            .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 2)
    }
}
