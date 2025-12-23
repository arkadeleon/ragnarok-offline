//
//  ToolbarCancelButton.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/12/23.
//

import SwiftUI

struct ToolbarCancelButton: ToolbarContent {
    var action: () -> Void

    var body: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            if #available(iOS 26.0, *) {
                Button("Cancel", systemImage: "xmark", action: action)
            } else {
                Button("Cancel", action: action)
            }
        }
    }
}
