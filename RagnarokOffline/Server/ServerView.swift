//
//  ServerView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/4/11.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import SwiftUI
import rAthenaCommon

struct ServerView: View {
    let server: RAServer

    private let terminalView = TerminalView()

    private let timer =  Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()

    @State private var isServerRunning = false

    var body: some View {
        HStack(spacing: 0) {
            VStack {
                HStack(spacing: 8) {
                    Text(server.name.uppercased())
                        .font(.subheadline)

                    Spacer()

                    if !isServerRunning {
                        Button {
                            server.start()
                        } label: {
                            Image(systemName: "play")
                        }
                        .frame(width: 32, height: 32)
                    } else {
                        Button {
                            server.stop()
                        } label: {
                            Image(systemName: "stop")
                        }
                        .frame(width: 32, height: 32)
                    }

                    Button {
                        terminalView.clear()
                    } label: {
                        Image(systemName: "trash")
                    }
                    .frame(width: 32, height: 32)
                }
                .frame(height: 32)
                .padding(.horizontal, 8)
                .background(Color(uiColor: .secondarySystemBackground))

                terminalView
            }
        }
        .cornerRadius(16)
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(uiColor: .secondarySystemBackground), lineWidth: 1)
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
            isServerRunning = server.status == .running
        }
    }
}

struct ServerView_Previews: PreviewProvider {
    static var previews: some View {
        ServerView(server: RAServer())
    }
}
