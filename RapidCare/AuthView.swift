//
//  AuthView.swift
//  RapidCare
//
//  Created by Scelo Kevin on 2026/10/07.
//


import SwiftUI

struct AuthView: View {
    @EnvironmentObject private var authManager: AuthManager
    @State private var selectedSegment: Int = 0 // 0: Login, 1: Register

    // Form fields
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var name: String = ""
    @State private var surname: String = ""
    @State private var selectedUserType: AppUserType = .user

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Brand
                    VStack(spacing: 8) {
                        Image(systemName: "cross.case.fill")
                            .font(.system(size: 54))
                            .foregroundStyle(RapidCareColor.brickEmber)

                        Text("RapidCare")
                            .font(.title.weight(.bold))
                            .foregroundStyle(RapidCareColor.onyx)

                        Text("Emergency dispatch & triage response")
                            .font(.subheadline)
                            .foregroundStyle(RapidCareColor.onyx.opacity(0.6))
                    }
                    .padding(.top, 24)

                    // Mode Picker
                    Picker("Mode", selection: $selectedSegment) {
                        Text("Log In").tag(0)
                        Text("Register").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 24)

                    // Error Alert Banner
                    if let err = authManager.authError {
                        Text(err)
                            .font(.footnote)
                            .foregroundStyle(RapidCareColor.brickEmber)
                            .padding(10)
                            .frame(maxWidth: .infinity)
                            .background(RapidCareColor.brickEmber.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding(.horizontal, 24)
                    }

                    // Form Fields
                    VStack(spacing: 14) {
                        if selectedSegment == 1 {
                            // First & Last Name
                            inputContainer(icon: "person.fill") {
                                TextField("First Name", text: $name)
                            }
                            inputContainer(icon: "person.text.rectangle.fill") {
                                TextField("Surname", text: $surname)
                            }

                            // User Type Dropdown
                            VStack(alignment: .leading, spacing: 6) {
                                Text("ACCOUNT TYPE")
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(RapidCareColor.onyx.opacity(0.6))
                                    .padding(.leading, 4)

                                Menu {
                                    Picker("User Type", selection: $selectedUserType) {
                                        ForEach(AppUserType.allCases) { type in
                                            Text(type.displayName).tag(type)
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Image(systemName: "person.badge.key.fill")
                                            .foregroundStyle(RapidCareColor.cerulean)
                                        Text(selectedUserType.displayName)
                                            .foregroundStyle(RapidCareColor.onyx)
                                        Spacer()
                                        Image(systemName: "chevron.up.chevron.down")
                                            .font(.caption)
                                            .foregroundStyle(RapidCareColor.onyx.opacity(0.4))
                                    }
                                    .padding(14)
                                    .background(Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .strokeBorder(Color.black.opacity(0.08), lineWidth: 1)
                                    )
                                }
                            }
                        }

                        // Email
                        inputContainer(icon: "envelope.fill") {
                            TextField("Email Address", text: $email)
                                .keyboardType(.emailAddress)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                        }

                        // Password with Eye Icon
                        PasswordInputField(
                            placeholder: selectedSegment == 0 ? "Enter Password" : "Create Password",
                            text: $password
                        )
                    }
                    .padding(.horizontal, 24)

                    // Action Button
                    Button {
                        Task {
                            if selectedSegment == 0 {
                                _ = await authManager.login(email: email, password: password)
                            } else {
                                _ = await authManager.register(
                                    name: name,
                                    surname: surname,
                                    email: email,
                                    password: password,
                                    type: selectedUserType
                                )
                            }
                        }
                    } label: {
                        HStack {
                            if authManager.isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text(selectedSegment == 0 ? "Sign In" : "Create Account")
                                    .fontWeight(.bold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(RapidCareColor.brickEmber)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(.pressable)
                    .disabled(authManager.isLoading)
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 32)
            }
            .background(RapidCareColor.porcelain.ignoresSafeArea())
        }
    }

    private func inputContainer<Content: View>(icon: String, @ViewBuilder content: () -> Content) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(RapidCareColor.onyx.opacity(0.4))
                .frame(width: 20)
            content()
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