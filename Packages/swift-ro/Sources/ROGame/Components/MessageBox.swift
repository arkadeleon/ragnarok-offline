//
//  MessageBox.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/9/9.
//

import ROResources
import SwiftUI

struct MessageBox: View {
    var message: String

    var body: some View {
        ZStack {
            ROImage("win_msgbox")

            Text(message)
        }
        .frame(width: 280, height: 120)
    }

    init(_ message: String) {
        self.message = message
    }
}

#Preview {
    MessageBox(MessageStringTable.shared.localizedMessageString(at: 121))
}
