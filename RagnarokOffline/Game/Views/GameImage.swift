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
            let path = "data/texture/유저인터페이스/\(name)"

            let url = ClientResourceManager.default.baseURL.appending(path: path)
            if FileManager.default.fileExists(atPath: url.path()),
               let data = try? Data(contentsOf: url) {
                image = CGImageCreateWithData(data)?.removingMagentaPixels()
                return
            }

            let grfPath = GRF.Path(string: path.replacingOccurrences(of: "/", with: "\\"))
            if let image = await ClientResourceManager.default.image(forBMPPath: grfPath) {
                self.image = image
                return
            }

            if let url = Bundle.main.resourceURL?.appending(path: path),
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
