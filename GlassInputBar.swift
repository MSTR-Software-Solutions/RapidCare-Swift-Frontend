//
//  GlassInputBar.swift
//  RapidCare
//
//  Created by Scelo Kevin on 2026/07/19.
//

import SwiftUI

/// The floating message composer, styled with Liquid Glass on iOS 26+ and a
/// Material-based fallback on earlier versions.
struct GlassInputBar: View {
    @Binding var text: String
    let isSending: Bool
    let isSessionActive: Bool
    let onSend: () -> Void

    @FocusState private var isFocused: Bool

    private var canSend: Bool {
        isSessionActive && !isSending && !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        HStack(spacing: 12) {
            TextField("Message RapidCare...", text: $text, axis: .vertical)
                .font(.body)
                .foregroundStyle(RapidCareColor.onyx)
                .tint(RapidCareColor.cerulean)
                .lineLimit(1...4)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(RapidCareColor.porcelain)
                )
                .focused($isFocused)
                .disabled(!isSessionActive || isSending)
                .accessibilityLabel("Message input")

            sendButton
        }
        .padding(10)
        .background(composerBackground)
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }

    @ViewBuilder
    private var composerBackground: some View {
        let shape = RoundedRectangle(cornerRadius: RapidCareMetrics.composerCornerRadius, style: .continuous)
        if #available(iOS 26, *) {
            shape
                .fill(.clear)
                .glassEffect(.regular, in: shape)
        } else {
            shape
                .fill(.regularMaterial)
                .overlay(
                    shape.strokeBorder(RapidCareColor.cerulean.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
        }
    }

    private var sendButton: some View {
        Button(action: onSend) {
            Image(systemName: "arrow.up")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
                .frame(
                    width: RapidCareMetrics.minimumTouchTarget,
                    height: RapidCareMetrics.minimumTouchTarget
                )
                .background(sendButtonBackground)
                .clipShape(Circle())
        }
        .buttonStyle(.pressable)
        .shadow(color: RapidCareColor.cerulean.opacity(0.3), radius: 6, x: 0, y: 3)
        .disabled(!canSend)
        .opacity(canSend ? 1 : 0.5)
        .accessibilityLabel("Send message")
    }

    @ViewBuilder
    private var sendButtonBackground: some View {
        if #available(iOS 26, *) {
            Circle()
                .fill(.clear)
                .glassEffect(.regular.tint(RapidCareColor.cerulean).interactive(), in: Circle())
        } else {
            Circle().fill(RapidCareColor.cerulean)
        }
    }
}
