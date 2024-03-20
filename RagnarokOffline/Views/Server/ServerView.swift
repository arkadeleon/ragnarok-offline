//
//  ServerView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/12/26.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import SwiftUI
import rAthenaCommon

struct ServerView: View {
    let server: RAServer

    private let terminalView = ServerTerminalView()

    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    @State private var serverStatus: RAServerStatus = .notStarted

    var body: some View {
        ZStack {
            terminalView
                .ignoresSafeArea(edges: .bottom)

            if serverStatus == .notStarted {
                Button {
                    Task {
                        await server.start()
                    }
                } label: {
                    Image(systemName: "play")
                        .font(.system(size: 40))
                        .padding(.horizontal, 15)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.bordered)
                .buttonBorderShape(.roundedRectangle)
            }
        }
        .navigationTitle(server.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    terminalView.clear()
                } label: {
                    Image(systemName: "trash")
                }
            }
        }
        .task {
            server.outputHandler = { data in
                if let data = String(data: data, encoding: .isoLatin1)?
                    .replacingOccurrences(of: "\n", with: "\r\n")
                    .data(using: .isoLatin1) {
                    terminalView.appendBuffer(data)
                }
            }
        }
        .onReceive(timer) { _ in
            serverStatus = server.status
        }
    }
}
