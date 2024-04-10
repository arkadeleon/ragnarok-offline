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
    @ObservedObject var server: ObservableServer

    private let terminalView = TerminalView()

    var body: some View {
        ZStack {
            terminalView
                .ignoresSafeArea(edges: .bottom)

            if server.status == .notStarted {
                Button {
                    server.start()
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
        .onAppear {
            terminalView.appendBuffer(server.cachedOutput)
            terminalView.scrollToEnd()
            server.outputHandler = { data in
                terminalView.appendBuffer(data)
            }
        }
        .onDisappear {
            server.outputHandler = nil
        }
    }
}
