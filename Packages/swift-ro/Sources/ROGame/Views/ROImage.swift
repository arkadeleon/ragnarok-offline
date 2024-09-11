//
//  ROImage.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/9/9.
//

import ROResources
import SwiftUI

struct ROImage: View {
    var name: String

    @State private var image: CGImage?

    var body: some View {
        ZStack {
            if let image {
                Image(decorative: image, scale: 1)
            }
        }
        .task {
            image = resourceBundle.image(forResource: name, withExtension: "bmp", locale: .current)
        }
    }

    init(_ name: String) {
        self.name = name
    }
}

#Preview {
    ROImage("win_msgbox")
}
