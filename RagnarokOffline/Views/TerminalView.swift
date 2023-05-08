//
//  TerminalView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/4/11.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import SwiftUI
import Terminal

struct TerminalView: UIViewRepresentable {
    private let terminalView = Terminal.TerminalView()

    func makeUIView(context: Context) -> Terminal.TerminalView {
        return terminalView
    }

    func updateUIView(_ terminalView: Terminal.TerminalView, context: Context) {
    }

    func appendBuffer(_ buffer: Data) {
        terminalView.appendBuffer(buffer)
    }

    func clear() {
        terminalView.terminalClear(.reset)
    }
}

struct TerminalView_Previews: PreviewProvider {
    static var previews: some View {
        TerminalView()
    }
}
