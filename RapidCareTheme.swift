//
//  RapidCareTheme.swift
//  RapidCare
//
//  Created by Scelo Kevin on 2026/07/19.
//

import SwiftUI

extension Color {
    /// Initializes a Color from a 6-digit hex string (with or without a leading #).
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var rgbValue: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&rgbValue)

        let r = Double((rgbValue & 0xFF0000) >> 16) / 255
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255
        let b = Double(rgbValue & 0x0000FF) / 255

        self.init(red: r, green: g, blue: b)
    }
}

/// RapidCare's fixed brand palette. Only these five colors should be used
/// anywhere in the UI -- no gradients, no ad-hoc colors.
enum RapidCareColor {
    static let darkCyan = Color(hex: "119DA4")    // primary accent, outgoing bubbles
    static let cerulean = Color(hex: "0C7489")     // secondary accent, buttons
    static let onyx = Color(hex: "0C120C")         // primary text
    static let porcelain = Color(hex: "FFFDF7")    // backgrounds, incoming bubbles
    static let brickEmber = Color(hex: "C20114")   // errors, destructive actions
}

/// Shared layout constants so spacing/radii stay consistent across components.
enum RapidCareMetrics {
    static let bubbleCornerRadius: CGFloat = 20
    static let composerCornerRadius: CGFloat = 26
    static let minimumTouchTarget: CGFloat = 44
}
