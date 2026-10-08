import SwiftUI

struct EmergencyCaseView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = EmergencyCaseViewModel()

    @State private var selectedEmergencyType: String = "Medical Emergency"
    @State private var notes: String = ""
    @State private var contactNumber: String = ""
    @State private var locationAddress: String = ""
    @State private var selectedTab: Int = 0 // 0: New Request, 1: History

    private let emergencyCategories = [
        "Cardiac Arrest",
        "Severe Trauma",
        "Breathing Distress",
        "Vehicle Accident",
        "Choking / Obstruction",
        "Other"
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Section", selection: $selectedTab) {
                    Text("New Request").tag(0)
                    Text("History").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.top, 12)

                if selectedTab == 0 {
                    requestFormView
                } else {
                    historyListView
                }
            }
            .background(RapidCareColor.porcelain.ignoresSafeArea())
            .navigationTitle("Emergency Dispatch")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Notice", isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .task {
                await viewModel.loadUserCases()
            }
        }
    }

    // MARK: - Form View
    @EnvironmentObject private var authManager: AuthManager

        // In requestFormView:
        private var requestFormView: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Admin permission check banner
                    if let user = authManager.currentUser, !user.canCreateEmergencyCase {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "lock.shield.fill")
                                    .font(.title2)
                                    .foregroundStyle(RapidCareColor.brickEmber)
                                Text("Administrator Access Required")
                                    .font(.headline)
                                    .foregroundStyle(RapidCareColor.onyx)
                            }
                            Text("Only designated Administrators or Emergency Operators are authorized to dispatch emergency cases. Regular accounts can monitor active cases and emergency history.")
                                .font(.footnote)
                                .foregroundStyle(RapidCareColor.onyx.opacity(0.7))
                        }
                        .padding(16)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .strokeBorder(RapidCareColor.brickEmber.opacity(0.3), lineWidth: 1)
                        )
                    }

                // Emergency Type Selector
                VStack(alignment: .leading, spacing: 10) {
                    Text("EMERGENCY TYPE")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(RapidCareColor.onyx.opacity(0.6))

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                        ForEach(emergencyCategories, id: \.self) { category in
                            Button {
                                selectedEmergencyType = category
                            } label: {
                                Text(category)
                                    .font(.subheadline.weight(.medium))
                                    .padding(.vertical, 12)
                                    .frame(maxWidth: .infinity)
                                    .background(selectedEmergencyType == category ? RapidCareColor.brickEmber : Color.white)
                                    .foregroundStyle(selectedEmergencyType == category ? .white : RapidCareColor.onyx)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .strokeBorder(
                                                selectedEmergencyType == category ? RapidCareColor.brickEmber : Color.black.opacity(0.08),
                                                lineWidth: 1
                                            )
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                // Situation & Location
                VStack(alignment: .leading, spacing: 10) {
                    Text("SITUATION & LOCATION DETAILS")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(RapidCareColor.onyx.opacity(0.6))

                    TextField("Address / Landmarks (e.g. 14 Smith Street, Durban)", text: $locationAddress)
                        .padding(12)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(Color.black.opacity(0.08), lineWidth: 1)
                        )

                    TextField("Describe symptoms, floor/flat number, triage notes...", text: $notes, axis: .vertical)
                        .lineLimit(3...5)
                        .padding(12)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(Color.black.opacity(0.08), lineWidth: 1)
                        )

                    TextField("Callback phone number (optional)", text: $contactNumber)
                        .keyboardType(.phonePad)
                        .padding(12)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(Color.black.opacity(0.08), lineWidth: 1)
                        )
                }

                // Submit Button
            let isAdmin = authManager.currentUser?.canCreateEmergencyCase ?? false

                            Button {
                                Task {
                                    let success = await viewModel.submitCase(
                                        type: selectedEmergencyType,
                                        description: notes,
                                        location: locationAddress
                                    )
                                    if success {
                                        selectedTab = 1
                                        notes = ""
                                        locationAddress = ""
                                    }
                                }
                            } label: {
                                HStack {
                                    if viewModel.isSubmitting {
                                        ProgressView().tint(.white)
                                    } else {
                                        Image(systemName: isAdmin ? "cross.fill" : "lock.fill")
                                        Text(isAdmin ? "Dispatch Medical Team" : "Admin Dispatch Only")
                                            .fontWeight(.bold)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(isAdmin ? RapidCareColor.brickEmber : Color.gray)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                            .buttonStyle(.pressable)
                            .disabled(!isAdmin || notes.trimmingCharacters(in: .whitespaces).isEmpty || viewModel.isSubmitting)
                        }
                        .padding(16)
                    }
    
    }

    // MARK: - History / Cases List
    private var historyListView: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Fetching requests...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.userCases.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "tray")
                        .font(.system(size: 40))
                        .foregroundStyle(RapidCareColor.onyx.opacity(0.3))
                    Text("No dispatch requests yet")
                        .font(.subheadline)
                        .foregroundStyle(RapidCareColor.onyx.opacity(0.5))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(viewModel.userCases) { item in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(item.displayTitle)
                                .font(.headline)
                                .foregroundStyle(RapidCareColor.onyx)
                            Spacer()
                            Text(item.displayStatus)
                                .font(.caption2.weight(.bold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(statusColor(item.displayStatus).opacity(0.15))
                                .foregroundStyle(statusColor(item.displayStatus))
                                .clipShape(Capsule())
                        }

                        Text(item.displayEmergencyType)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(RapidCareColor.cerulean)

                        Text(item.displayDescription)
                            .font(.footnote)
                            .foregroundStyle(RapidCareColor.onyx.opacity(0.75))
                            .lineLimit(2)

                        if let date = item.createdAt {
                            Text(date, style: .date)
                                .font(.caption2)
                                .foregroundStyle(RapidCareColor.onyx.opacity(0.4))
                        }
                    }
                    .padding(.vertical, 4)
                }
                .listStyle(.insetGrouped)
                .refreshable {
                    await viewModel.loadUserCases()
                }
            }
        }
    }

    private func statusColor(_ status: String) -> Color {
        switch status.uppercased() {
        case "PENDING":
            return Color.orange
        case "DISPATCHED", "EN_ROUTE":
            return RapidCareColor.cerulean
        case "RESOLVED":
            return Color.green
        case "CANCELLED":
            return Color.gray
        default:
            return RapidCareColor.cerulean
        }
    }
}
