//
//  ROButton.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/9/9.
//

import SwiftUI

struct ROButton: View {
    var imageName: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            ROImage(imageName)
        }
//        .buttonStyle(.ro(imageName))
    }

    init(_ imageName: String, action: @escaping () -> Void) {
        self.imageName = imageName
        self.action = action
    }
}

struct ROButtonStyle: ButtonStyle {
    var imageName: String

    init(_ imageName: String) {
        self.imageName = imageName
    }

    func makeBody(configuration: Configuration) -> some View {
        if configuration.isPressed {
            ROImage(imageName + "_b")
        } else {
            ROImage(imageName)
        }
    }
}

extension ButtonStyle where Self == ROButtonStyle {
    static func ro(_ imageName: String) -> ROButtonStyle {
        ROButtonStyle(imageName)
    }
}

#Preview {
    ROButton("btn_ok") {
    }
}
