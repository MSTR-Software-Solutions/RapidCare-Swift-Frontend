//
//  EmergencyCaseView.swift
//  RapidCare
//
//  Created by Scelo Kevin on 2026/09/05.
//


import SwiftUI
import CoreLocation

struct EmergencyCaseView: View {
    @StateObject private var viewModel = EmergencyCaseViewModel()
    @Environment(\.dismiss) private var dismiss
    
    // In production, inject from auth session
    let currentUserId: Int = 1 
    
    var body: some View {
        NavigationStack {
            ZStack {
                RapidCareColor.porcelain
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        headerNotice
                        
                        locationSection
                        
                        incidentClassificationSection
                        
                        severitySection
                        
                        descriptionSection
                        
                        submitButton
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
                
                if viewModel.isSubmitting {
                    LoadingView()
                }
            }
            .navigationTitle("Request Emergency Dispatch")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(RapidCareColor.cerulean)
                }
            }
            .onAppear {
                viewModel.locationManager.requestLocation()
            }
            .alert("Dispatch Initiated", isPresented: Binding(
                get: { viewModel.submittedCase != nil },
                set: { if !$0 { viewModel.submittedCase = nil; dismiss() } }
            )) {
                Button("OK", role: .cancel) { dismiss() }
            } message: {
                Text("Case #\(viewModel.submittedCase?.caseID ?? 0) has been created. First responders are being notified.")
            }
            .alert("Error", isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
        .tint(RapidCareColor.cerulean)
    }
    
    // MARK: - Subviews
    
    private var headerNotice: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.title2)
                .foregroundStyle(RapidCareColor.brickEmber)
            
            Text("If this is an immediate, critical emergency, please dial local South African emergency services (10177 or 112) first.")
                .font(.subheadline)
                .foregroundStyle(RapidCareColor.onyx)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(RapidCareColor.brickEmber.opacity(0.12))
        )
    }
    
    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("LOCATION")
                .font(.caption.weight(.bold))
                .foregroundStyle(RapidCareColor.onyx.opacity(0.6))
            
            HStack {
                Image(systemName: "mappin.and.ellipse")
                    .foregroundStyle(RapidCareColor.cerulean)
                
                TextField("Street Address, Landmark, or City", text: $viewModel.locationName)
                    .font(.body)
                    .foregroundStyle(RapidCareColor.onyx)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white)
                    .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(RapidCareColor.cerulean.opacity(0.2), lineWidth: 1))
            )
            
            if let loc = viewModel.locationManager.location {
                Text("GPS: \(loc.coordinate.latitude, specifier: "%.4f"), \(loc.coordinate.longitude, specifier: "%.4f")")
                    .font(.caption2)
                    .foregroundStyle(RapidCareColor.onyx.opacity(0.5))
            }
        }
    }
    
    private var incidentClassificationSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("INCIDENT DETAILS")
                .font(.caption.weight(.bold))
                .foregroundStyle(RapidCareColor.onyx.opacity(0.6))
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Incident Category")
                    .font(.footnote)
                    .foregroundStyle(RapidCareColor.onyx)
                
                Picker("Incident Type", selection: $viewModel.incidentType) {
                    ForEach(IncidentType.allCases) { type in
                        Text(type.displayName).tag(type)
                    }
                }
                .pickerStyle(.menu)
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(RapidCareColor.cerulean.opacity(0.2), lineWidth: 1))
            }
            
            if viewModel.incidentType == .medicalEmergency {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Medical Type")
                        .font(.footnote)
                        .foregroundStyle(RapidCareColor.onyx)
                    
                    Picker("Medical Type", selection: $viewModel.medicalEmergencyType) {
                        ForEach(MedicalEmergencyType.allCases) { medType in
                            Text(medType.displayName).tag(medType)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(RapidCareColor.cerulean.opacity(0.2), lineWidth: 1))
                }
            }
        }
    }
    
    private var severitySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("SEVERITY")
                .font(.caption.weight(.bold))
                .foregroundStyle(RapidCareColor.onyx.opacity(0.6))
            
            Picker("Severity", selection: $viewModel.severityLevel) {
                ForEach(SeverityLevel.allCases) { level in
                    Text(level.displayName).tag(level)
                }
            }
            .pickerStyle(.segmented)
        }
    }
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("DESCRIPTION & SYMPTOMS")
                .font(.caption.weight(.bold))
                .foregroundStyle(RapidCareColor.onyx.opacity(0.6))
            
            TextField("Describe the situation, patient condition, or scene hazards...", text: $viewModel.incidentDescription, axis: .vertical)
                .lineLimit(4...6)
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.white)
                        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(RapidCareColor.cerulean.opacity(0.2), lineWidth: 1))
                )
        }
    }
    
    private var submitButton: some View {
        Button {
            Task {
                await viewModel.submitCase(userId: currentUserId)
            }
        } label: {
            HStack {
                Image(systemName: "cross.fill")
                Text("Dispatch RapidCare")
                    .fontWeight(.bold)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(viewModel.canSubmit ? RapidCareColor.brickEmber : Color.gray.opacity(0.4))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: viewModel.canSubmit ? RapidCareColor.brickEmber.opacity(0.3) : .clear, radius: 8, y: 4)
        }
        .disabled(!viewModel.canSubmit)
        .padding(.top, 12)
    }
}

#Preview {
    EmergencyCaseView()
}
