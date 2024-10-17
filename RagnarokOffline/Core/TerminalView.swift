//
//  TerminalView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/2/14.
//

import SwiftUI

#if os(macOS)

struct TerminalViewContainer: NSViewRepresentable {
    var terminalView: TerminalView

    func makeNSView(context: Context) -> TerminalView {
        return terminalView
    }

    func updateNSView(_ nsView: TerminalView, context: Context) {
    }
}

#else

struct TerminalViewContainer: UIViewRepresentable {
    var terminalView: TerminalView

    func makeUIView(context: Context) -> TerminalView {
        return terminalView
    }

    func updateUIView(_ uiView: TerminalView, context: Context) {
    }
}

#endif

#if os(iOS)

import Terminal

class TerminalView: UIView {
    var terminalView: Terminal.TerminalView!

    override init(frame: CGRect) {
        super.init(frame: frame)

        terminalView = Terminal.TerminalView(frame: bounds)
        terminalView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        terminalView.terminalFontSize = 12
        addSubview(terminalView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func feed(text: String) {
        if let data = text.data(using: .utf8) {
            terminalView.appendBuffer(data)
        }
    }
}

#else

import SwiftTerm

class TerminalView: SwiftTerm.TerminalView {
//    override var canBecomeFirstResponder: Bool {
//        false
//    }
//
//    override var canBecomeFocused: Bool {
//        false
//    }
}

#endif
