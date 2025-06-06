//
//  MessageBoxView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/9/9.
//

import ROResources
import SwiftUI

struct MessageBoxView: View {
    var message: String

    var body: some View {
        ZStack {
            GameImage("win_msgbox.bmp")

            GameText(message)
        }
        .frame(width: 280, height: 120)
    }

    init(_ message: String) {
        self.message = message
    }
}

#Preview {
    MessageBoxView("Please wait...")
        .padding()
}
