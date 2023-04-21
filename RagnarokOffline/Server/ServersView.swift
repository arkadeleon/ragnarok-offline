//
//  ServersView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/4/11.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import SwiftUI
import rAthenaCommon
import rAthenaLogin
import rAthenaChar
import rAthenaMap
import rAthenaWeb

struct ServersView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        GeometryReader { geometry in
            if horizontalSizeClass == .compact {
                VStack(spacing: 16) {
                    ServerView(server: RALoginServer.shared)
                        .frame(width: geometry.size.width - 16 * 2, height: (geometry.size.height - 16 * 5) / 4)

                    ServerView(server: RACharServer.shared)
                        .frame(width: geometry.size.width - 16 * 2, height: (geometry.size.height - 16 * 5) / 4)

                    ServerView(server: RAMapServer.shared)
                        .frame(width: geometry.size.width - 16 * 2, height: (geometry.size.height - 16 * 5) / 4)

                    ServerView(server: RAWebServer.shared)
                        .frame(width: geometry.size.width - 16 * 2, height: (geometry.size.height - 16 * 5) / 4)
                }
                .padding(16)
            } else {
                VStack(spacing: 16) {
                    HStack(spacing: 16) {
                        ServerView(server: RALoginServer.shared)
                            .frame(width: (geometry.size.width - 16 * 3) / 2, height: (geometry.size.height - 16 * 3) / 2)

                        ServerView(server: RACharServer.shared)
                            .frame(width: (geometry.size.width - 16 * 3) / 2, height: (geometry.size.height - 16 * 3) / 2)
                    }

                    HStack(spacing: 16) {
                        ServerView(server: RAMapServer.shared)
                            .frame(width: (geometry.size.width - 16 * 3) / 2, height: (geometry.size.height - 16 * 3) / 2)

                        ServerView(server: RAWebServer.shared)
                            .frame(width: (geometry.size.width - 16 * 3) / 2, height: (geometry.size.height - 16 * 3) / 2)
                    }
                }
                .padding(16)
            }
        }
        .navigationTitle("Server")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            RAResourceManager.shared.copyResourcesToLibraryDirectory()
        }
    }
}

struct ServersView_Previews: PreviewProvider {
    static var previews: some View {
        ServersView()
    }
}
