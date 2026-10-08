import SwiftUI

/// Full-screen loading state shown while a chat session is being started.
struct LoadingView: View {
    var body: some View {
        ZStack {
            RapidCareColor.porcelain
                .ignoresSafeArea()

            VStack(spacing: 20) {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(RapidCareColor.cerulean)
                    .scaleEffect(1.4)

                Text("Connecting to RapidCare...")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(RapidCareColor.onyx.opacity(0.7))
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Connecting to RapidCare")
    }
}

#Preview {
    LoadingView()
}
