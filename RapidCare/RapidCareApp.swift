//
//  RapidCareApp.swift
//  RapidCare
//
//  Created by Scelo Kevin on 2026/07/19.
//

import SwiftUI

@main
struct RapidCareApp: App {
    @StateObject private var authManager = AuthManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
        }
    }
}
