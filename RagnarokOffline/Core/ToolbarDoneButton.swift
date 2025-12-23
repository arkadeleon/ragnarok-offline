//
//  ToolbarDoneButton.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/12/23.
//

import SwiftUI

struct ToolbarDoneButton: ToolbarContent {
    var action: () -> Void

    var body: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            if #available(iOS 26.0, *) {
                Button("Done", systemImage: "checkmark", action: action)
            } else {
                Button("Done", action: action)
            }
        }
    }
}
