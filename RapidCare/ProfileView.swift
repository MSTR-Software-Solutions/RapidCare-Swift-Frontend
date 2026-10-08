//
//  ProfileView.swift
//  RapidCare
//
//  Created by Scelo Kevin on 2026/10/07.
//


import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var authManager: AuthManager

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if let user = authManager.currentUser {
                        // User Avatar & Name Banner
                        VStack(spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(RapidCareColor.cerulean.opacity(0.15))
                                    .frame(width: 84, height: 84)

                                Text(String(user.userName.prefix(1)) + String(user.userSurname.prefix(1)))
                                    .font(.title.weight(.bold))
                                    .foregroundStyle(RapidCareColor.cerulean)
                            }

                            Text(user.fullName)
                                .font(.title2.weight(.bold))
                                .foregroundStyle(RapidCareColor.onyx)

                            Text(user.email)
                                .font(.subheadline)
                                .foregroundStyle(RapidCareColor.onyx.opacity(0.6))

                            // Role Badge
                            Text(user.userType.uppercased())
                                .font(.caption.weight(.heavy))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(user.canCreateEmergencyCase ? RapidCareColor.brickEmber.opacity(0.15) : RapidCareColor.cerulean.opacity(0.15))
                                .foregroundStyle(user.canCreateEmergencyCase ? RapidCareColor.brickEmber : RapidCareColor.cerulean)
                                .clipShape(Capsule())
                        }
                        .frame(maxWidth: .infinity)
                        .padding(20)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20))

                        // Permissions & Details Card
                        VStack(alignment: .leading, spacing: 14) {
                            Text("ACCOUNT INFORMATION")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(RapidCareColor.onyx.opacity(0.6))

                            infoRow(title: "User ID", value: "#\(user.userId)", icon: "number")
                            infoRow(title: "Role", value: user.userType, icon: "person.badge.shield.checkmark.fill")
                            infoRow(title: "Phone", value: user.phone ?? "Not provided", icon: "phone.fill")
                            infoRow(
                                title: "Dispatch Authority",
                                value: user.canCreateEmergencyCase ? "Authorized (Admin/Operator)" : "Restricted (User)",
                                icon: user.canCreateEmergencyCase ? "checkmark.seal.fill" : "lock.shield.fill"
                            )
                        }
                        .padding(18)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 18))

                        // Logout Button
                        Button(role: .destructive) {
                            authManager.logout()
                        } label: {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("Log Out")
                                    .fontWeight(.bold)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.red.opacity(0.1))
                            .foregroundStyle(Color.red)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .buttonStyle(.pressable)
                        .padding(.top, 10)
                    }
                }
                .padding(20)
            }
            .background(RapidCareColor.porcelain.ignoresSafeArea())
            .navigationTitle("Profile")
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }

    private func infoRow(title: String, value: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(RapidCareColor.cerulean)
                .frame(width: 22)
            Text(title)
                .font(.subheadline)
                .foregroundStyle(RapidCareColor.onyx.opacity(0.7))
            Spacer()
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(RapidCareColor.onyx)
        }
    }
}