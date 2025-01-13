//
//  GameImage.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/9/9.
//

import ROClientResources
import ROCore
import ROFileFormats
import SwiftUI

struct GameImage: View {
    var name: String

    @State private var image: CGImage?

    var body: some View {
        ZStack {
            if let image {
                Image(decorative: image, scale: 1)
            }
        }
        .task {
            let components = ["data", "texture", "유저인터페이스", name]

            let url = GameResourceManager.default.baseURL.appending(component: components.joined(separator: "/"))
            if FileManager.default.fileExists(atPath: url.path()),
               let data = try? Data(contentsOf: url) {
                image = CGImageCreateWithData(data)?.removingMagentaPixels()
                return
            }

            let grfPath = GRF.Path(components: components)
            if let image = await GameResourceManager.default.image(forBMPPath: grfPath) {
                self.image = image
                return
            }

            if let url = Bundle.main.resourceURL?.appending(component: components.joined(separator: "/")),
               let data = try? Data(contentsOf: url) {
                image = CGImageCreateWithData(data)?.removingMagentaPixels()
            }
        }
    }

    init(_ name: String) {
        self.name = name
    }
}

#Preview {
    GameImage("win_msgbox.bmp")
}
