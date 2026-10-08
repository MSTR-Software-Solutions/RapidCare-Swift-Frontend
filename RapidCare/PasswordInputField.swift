//
//  PasswordInputField.swift
//  RapidCare
//
//  Created by Scelo Kevin on 2026/10/07.
//


import SwiftUI

struct PasswordInputField: View {
    let placeholder: String
    @Binding var text: String
    @State private var isVisible: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "lock.fill")
                .foregroundStyle(RapidCareColor.onyx.opacity(0.4))
                .frame(width: 20)

            if isVisible {
                TextField(placeholder, text: $text)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
            } else {
                SecureField(placeholder, text: $text)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
            }

            Button {
                isVisible.toggle()
            } label: {
                Image(systemName: isVisible ? "eye.slash.fill" : "eye.fill")
                    .foregroundStyle(RapidCareColor.onyx.opacity(0.5))
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.black.opacity(0.08), lineWidth: 1)
        )
    }
}