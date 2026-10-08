//
//  PressableButtonStyle.swift
//  RapidCare
//
//  Created by Scelo Kevin on 2026/07/19.
//

import SwiftUI

/// A subtle press-scale effect for toolbar/utility buttons, matching Apple's
/// understated interaction style rather than anything flashy.
struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == PressableButtonStyle {
    static var pressable: PressableButtonStyle { PressableButtonStyle() }
}
