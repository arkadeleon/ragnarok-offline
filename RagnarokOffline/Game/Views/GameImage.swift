//
//  GameImage.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/9/9.
//

import ROCore
import RORendering
import ROResources
import SwiftUI

struct GameImage<Content>: View where Content: View {
    var name: String
    var content: (CGImage) -> Content

    @State private var image: CGImage?

    var body: some View {
        contentView
            .task {
                let components = name.split(separator: "/").map(String.init)
                let path = ResourcePath.userInterface.appending(components: components)
                image = try? await ResourceManager.default.image(at: path, removesMagentaPixels: true)
            }
    }

    @ViewBuilder private var contentView: some View {
        if let image {
            content(image)
        } else {
            Image(decorative: "")
        }
    }

    init(_ name: String) where Content == Image {
        self.name = name
        self.content = { image in
            Image(decorative: image, scale: 1)
        }
    }

    init(_ name: String, @ViewBuilder content: @escaping (Image) -> Content) {
        self.name = name
        self.content = { image in
            content(Image(decorative: image, scale: 1))
        }
    }
}

#Preview {
    GameImage("win_msgbox.bmp")
        .frame(width: 280, height: 120)
        .padding()
}
