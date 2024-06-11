//
//  GNDFilePreviewView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/5/16.
//

import RealityKit
import ROCore
import ROFileFormats
import SwiftUI

struct GNDFilePreviewView: View {
    var file: ObservableFile

    @State private var status: AsyncContentStatus<Entity> = .notYetLoaded

    var body: some View {
        AsyncContentView(status: status) { entity in
            ModelViewer(entity: entity)
        }
        .task {
            await loadGNDFile()
        }
    }

    private func loadGNDFile() async {
        guard case .notYetLoaded = status else {
            return
        }

        status = .loading

        guard case .grfEntry(let grf, let path) = file.file, let data = file.file.contents() else {
            return
        }

        guard let gnd = try? GND(data: data) else {
            return
        }

        let gatPath = path.replacingExtension("gat")
        guard let gatData = try? grf.contentsOfEntry(at: gatPath),
              let gat = try? GAT(data: gatData)
        else {
            return
        }

        let entity = try? await Entity.loadGround(gat: gat, gnd: gnd) { textureName in
            let path = GRF.Path(string: "data\\texture\\" + textureName)
            guard let data = try? grf.contentsOfEntry(at: path) else {
                return nil
            }
            let texture = CGImageCreateWithData(data)
            return texture
        }

        if let entity {
            status = .loaded(entity)
        }
    }
}

//#Preview {
//    GNDFilePreviewView()
//}
