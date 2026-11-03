//
//  WelcomeView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2026/11/2.
//

import SwiftUI

struct WelcomeView: View {
    var onContinue: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                VStack(spacing: 16) {
                    Image(systemName: "gamecontroller.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(.tint)

                    Text("Welcome to RagOff")
                        .font(.largeTitle)
                        .bold()
                        .multilineTextAlignment(.center)

                    Text("Choose one of two ways to provide game resources: use a local client or a remote client. The Game Client, database icons and sprites, and tools all use these resources.")
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                VStack(alignment: .leading, spacing: 28) {
                    Label {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("1. Use Local Client")
                                .font(.headline)
                            Text("Add data.grf and the BGM folder to **Local Client Files** to use the app entirely offline.")
                                .foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: "folder.fill")
                            .font(.title)
                            .foregroundStyle(.tint)
                            .frame(width: 44)
                    }

                    Label {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("2. Use Remote Client")
                                .font(.headline)
                            Text("Download resources as needed instead of storing the full client.")
                                .foregroundStyle(.secondary)
                            Text("The app no longer provides a hosted remote client.")
                                .foregroundStyle(.orange)
                            Text("To use **Remote Client**, turn on **Use Remote Client** in **Settings** and enter your own URL.")
                                .foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: "cloud.fill")
                            .font(.title)
                            .foregroundStyle(.tint)
                            .frame(width: 44)
                    }
                }
            }
            .frame(maxWidth: 460)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 28)
            .padding(.top, 44)
            .padding(.bottom, 28)
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 16) {
                Text("You must have the rights or permission to use these files.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Button(action: onContinue) {
                    Text("Continue")
                        .font(.title3)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                }
                .adaptiveProminentButtonStyle()
                .keyboardShortcut(.defaultAction)
            }
            .frame(maxWidth: 460)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 28)
            .padding(.vertical, 24)
            .background(.background)
        }
        .interactiveDismissDisabled()
        #if os(macOS)
        .frame(width: 560, height: 680)
        #endif
    }
}

#Preview {
    WelcomeView(onContinue: {})
}
