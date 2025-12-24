//
//  ToolbarButtons.swift
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

struct ToolbarResetButton: ToolbarContent {
    var action: () -> Void

    var body: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Reset", action: action)
        }
    }
}
