//
//  ServerView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/12/26.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import SwiftUI

import rAthenaCommon
import rAthenaResource

struct ServerView: View {
    let server: RAServer

    private let terminalView = ServerTerminalView()

    private let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()

    @State private var isServerRunning = false

    var body: some View {
        ZStack {
            terminalView
        }
        .navigationTitle(server.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if !isServerRunning {
                    Button {
                        Task {
                            await server.start()
                        }
                    } label: {
                        Image(systemName: "play")
                    }
                } else {
                    Button {
                        Task {
                            await server.stop()
                        }
                    } label: {
                        Image(systemName: "stop")
                    }
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    terminalView.clear()
                } label: {
                    Image(systemName: "trash")
                }
            }
        }
        .task {
            Task {
                try ResourceManager.shared.copyResourceFilesToLibraryDirectory()

                server.outputHandler = { data in
                    if let data = String(data: data, encoding: .isoLatin1)?
                        .replacingOccurrences(of: "\n", with: "\r\n")
                        .data(using: .isoLatin1) {
                        terminalView.appendBuffer(data)
                    }
                }
            }
        }
        .onReceive(timer) { _ in
            isServerRunning = server.status == .running
        }
    }
}
