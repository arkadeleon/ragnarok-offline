//
//  MessageBoxView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/9/9.
//

import ROLocalizations
import SwiftUI

struct MessageBoxView: View {
    var message: String

    var body: some View {
        ZStack {
            GameImage("win_msgbox.bmp")

            Text(message)
                .font(.system(size: 12))
        }
        .frame(width: 280, height: 120)
    }

    init(_ message: String) {
        self.message = message
    }
}

#Preview {
    MessageBoxView(MessageStringTable.shared.localizedMessageString(at: 121))
}