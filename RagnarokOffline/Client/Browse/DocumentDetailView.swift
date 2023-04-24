//
//  DocumentDetailView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/4/7.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import SwiftUI

struct DocumentDetailView: View {

    let document: DocumentWrapper

    var body: some View {
        switch document.contentType {
        case .txt, .xml, .ini, .lua, .lub:
            TextDocumentView(document: document)
        case .bmp, .png, .jpg, .tga, .ebm, .pal:
            ImageDocumentView(document: document)
        case .mp3, .wav:
            AudioDocumentView(document: document)
        case .spr:
            SpriteDocumentView(document: document)
        case .act:
            ActionDocumentView(document: document)
        case .rsm:
            ModelDocumentView(document: document)
        case .rsw:
            WorldDocumentView(document: document)
        default:
            EmptyView()
        }
    }
}
