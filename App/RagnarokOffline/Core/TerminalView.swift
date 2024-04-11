//
//  TerminalView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/2/14.
//

import SwiftUI
import Terminal

struct TerminalView: UIViewRepresentable {
    private let terminalView: Terminal.TerminalView = {
        let terminalView = Terminal.TerminalView()
        terminalView.terminalFontSize = 12
        return terminalView
    }()

    func makeUIView(context: Context) -> Terminal.TerminalView {
        return terminalView
    }

    func updateUIView(_ terminalView: Terminal.TerminalView, context: Context) {
    }

    func appendBuffer(_ buffer: Data) {
        terminalView.appendBuffer(buffer)
    }

    func scrollToEnd() {
        terminalView.terminalScroll(.end)
    }

    func clear() {
        terminalView.terminalClear(.reset)
    }
}
