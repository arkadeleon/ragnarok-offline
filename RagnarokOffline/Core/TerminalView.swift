//
//  TerminalView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/2/14.
//

import SwiftUI

struct TerminalViewContainer: UIViewRepresentable {
    let terminalView: TerminalView

    func makeUIView(context: Context) -> TerminalView {
        return terminalView
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
    }
}

//import SwiftTerm
//
//class TerminalView: SwiftTerm.TerminalView {
//    override var canBecomeFirstResponder: Bool {
//        false
//    }
//
//    override var canBecomeFocused: Bool {
//        false
//    }
//}

import Terminal

typealias TerminalView = Terminal.TerminalView

extension Terminal.TerminalView {
    func feed(text: String) {
        if let data = text.data(using: .utf8) {
            appendBuffer(data)
        }
    }
}
