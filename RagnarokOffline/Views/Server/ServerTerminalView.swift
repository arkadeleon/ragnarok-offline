//
//  ServerTerminalView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/2/14.
//  Copyright © 2024 Leon & Vane. All rights reserved.
//

import SwiftUI
import Terminal

struct ServerTerminalView: UIViewRepresentable {
    private let terminalView: TerminalView = {
        let terminalView = TerminalView()
        terminalView.terminalFontSize = 12
        return terminalView
    }()

    func makeUIView(context: Context) -> TerminalView {
        return terminalView
    }

    func updateUIView(_ terminalView: TerminalView, context: Context) {
    }

    func appendBuffer(_ buffer: Data) {
        terminalView.appendBuffer(buffer)
    }

    func clear() {
        terminalView.terminalClear(.reset)
    }
}
