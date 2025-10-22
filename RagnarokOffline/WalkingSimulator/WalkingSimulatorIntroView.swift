//
//  WalkingSimulatorIntroView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/10/22.
//

import SwiftUI

struct WalkingSimulatorIntroView: View {
    @State private var betaLink: URL?

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                Image(systemName: "macwindow")
                    .font(.system(size: 60))
                    .foregroundStyle(.secondary)

                VStack(spacing: 8) {
                    Text("Walking Simulator")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text(verbatim: "Beta Access Required")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
            }

            VStack(spacing: 12) {
                Text(verbatim: "The Walking Simulator allows you to explore and walk through the game world.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)

                Text(verbatim: "This feature is currently available only for beta testers.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }


            Button {
                if let betaLink {
                    #if os(macOS)
                    NSWorkspace.shared.open(betaLink)
                    #else
                    UIApplication.shared.open(betaLink)
                    #endif
                }
            } label: {
                Text(verbatim: "Join Beta")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(12)
                    .background(Color.blue.opacity(betaLink == nil ? 0.5 : 1.0))
                    .cornerRadius(8)
            }
            .disabled(betaLink == nil)
        }
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("Walking Simulator")
        .task {
            do {
                let fetchURL = URL(string: "https://raw.githubusercontent.com/arkadeleon/ragnarok-offline/master/beta-link.json")!
                let (data, _) = try await URLSession.shared.data(from: fetchURL)
                let json = try JSONDecoder().decode([String : String].self, from: data)
                betaLink = json["link"].flatMap(URL.init)
            } catch {
                betaLink = URL(string: "https://testflight.apple.com/join/vRf81uWF")
            }
        }
    }
}

#Preview {
    WalkingSimulatorIntroView()
}
