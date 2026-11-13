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
            if #available(iOS 26.0, macOS 26.0, visionOS 26.0, *) {
                Button(role: .cancel, action: action)
            } else {
                Button("Cancel", action: action)
            }
        }
    }
}

struct ToolbarCloseButton: ToolbarContent {
    var action: () -> Void

    var body: some ToolbarContent {
        if #available(iOS 26.0, macOS 26.0, visionOS 26.0, *) {
            ToolbarItem(placement: .cancellationAction) {
                Button(role: .close, action: action)
            }
        } else {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done", action: action)
            }
        }
    }
}

struct ToolbarConfirmButton: ToolbarContent {
    var action: () -> Void

    var body: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            if #available(iOS 26.0, macOS 26.0, visionOS 26.0, *) {
                Button(role: .confirm, action: action)
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
