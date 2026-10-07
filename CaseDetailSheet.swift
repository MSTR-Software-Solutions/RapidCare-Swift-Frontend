import SwiftUI

struct CaseDetailSheet: View {
    let emergencyCase: EmergencyCase
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header Card
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(emergencyCase.displayTitle)
                                .font(.title2.weight(.bold))
                                .foregroundStyle(RapidCareColor.onyx)
                            Spacer()
                            statusBadge(emergencyCase.displayStatus)
                        }

                        Text("Case ID: #\(emergencyCase.caseId)")
                            .font(.caption)
                            .foregroundStyle(RapidCareColor.onyx.opacity(0.6))
                    }
                    .padding(16)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    // Key Information
                    VStack(alignment: .leading, spacing: 14) {
                        Text("INCIDENT OVERVIEW")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(RapidCareColor.onyx.opacity(0.6))

                        detailRow(title: "Type", value: emergencyCase.displayEmergencyType, icon: "cross.circle.fill")
                        
                        if let severity = emergencyCase.severityLevel {
                            detailRow(title: "Severity", value: severity, icon: "exclamationmark.triangle.fill")
                        }
                        
                        if let loc = emergencyCase.location {
                            detailRow(title: "Location", value: loc, icon: "mappin.and.ellipse")
                        } else if let lat = emergencyCase.latitude, let lon = emergencyCase.longitude {
                            detailRow(title: "Coordinates", value: String(format: "%.4f, %.4f", lat, lon), icon: "location.fill")
                        }
                    }
                    .padding(16)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    // Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("DESCRIPTION & NOTES")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(RapidCareColor.onyx.opacity(0.6))

                        Text(emergencyCase.displayDescription)
                            .font(.body)
                            .foregroundStyle(RapidCareColor.onyx)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(16)
            }
            .background(RapidCareColor.porcelain.ignoresSafeArea())
            .navigationTitle("Case Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(RapidCareColor.cerulean)
                }
            }
        }
    }

    private func detailRow(title: String, value: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(RapidCareColor.cerulean)
                .frame(width: 24)
            Text(title)
                .font(.subheadline)
                .foregroundStyle(RapidCareColor.onyx.opacity(0.7))
            Spacer()
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(RapidCareColor.onyx)
        }
    }

    private func statusBadge(_ status: String) -> some View {
        Text(status)
            .font(.caption2.weight(.bold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(RapidCareColor.cerulean.opacity(0.15))
            .foregroundStyle(RapidCareColor.cerulean)
            .clipShape(Capsule())
    }
}