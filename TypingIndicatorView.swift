//
//  TypingIndicatorView.swift
//  RapidCare
//
//  Created by Scelo Kevin on 2026/07/28.
//


import SwiftUI

/// Shown in place of the bot's reply while waiting for a response --
/// styled identically to an incoming bubble so it reads as "RapidCare is
/// composing a reply" rather than a generic spinner.
struct TypingIndicatorView: View {
    @State private var animatingDotIndex = 0
    @State private var timer: Timer?

    private let dotCount = 3
    private let animationInterval = 0.3

    var body: some View {
        HStack {
            HStack(spacing: 6) {
                ForEach(0..<dotCount, id: \.self) { index in
                    Circle()
                        .fill(RapidCareColor.cerulean.opacity(0.6))
                        .frame(width: 7, height: 7)
                        .scaleEffect(animatingDotIndex == index ? 1.2 : 0.7)
                        .opacity(animatingDotIndex == index ? 1.0 : 0.4)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: RapidCareMetrics.bubbleCornerRadius, style: .continuous)
                    .fill(RapidCareColor.porcelain)
                    .overlay(
                        RoundedRectangle(cornerRadius: RapidCareMetrics.bubbleCornerRadius, style: .continuous)
                            .strokeBorder(RapidCareColor.cerulean.opacity(0.25), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 2)
            )

            Spacer(minLength: 40)
        }
        .padding(.horizontal, 4)
        .transition(.opacity.combined(with: .scale(scale: 0.9, anchor: .leading)))
        .onAppear(perform: startAnimation)
        .onDisappear(perform: stopAnimation)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("RapidCare assistant is typing")
    }

    private func startAnimation() {
        timer = Timer.scheduledTimer(withTimeInterval: animationInterval, repeats: true) { _ in
            withAnimation(.easeInOut(duration: animationInterval)) {
                animatingDotIndex = (animatingDotIndex + 1) % dotCount
            }
        }
    }

    private func stopAnimation() {
        timer?.invalidate()
        timer = nil
    }
}

#Preview {
    TypingIndicatorView()
        .padding()
        .background(RapidCareColor.porcelain)
}