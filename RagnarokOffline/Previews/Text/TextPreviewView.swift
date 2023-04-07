//
//  TextPreviewView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/4/7.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import SwiftUI

struct TextPreviewView: View {

    let previewItem: PreviewItem

    @State private var htmlString = ""

    var body: some View {
        WebView(htmlString: htmlString)
            .navigationTitle(previewItem.title)
            .navigationBarTitleDisplayMode(.inline)
            .task {
                loadPreviewItem()
            }
    }

    private func loadPreviewItem() {
        guard var data = try? previewItem.data() else {
            return
        }

        switch previewItem.fileType {
        case .lub:
            let decompiler = LuaDecompiler()
            data = decompiler.decompileData(data)
        default:
            break
        }

        guard let text = String(data: data, encoding: .ascii) else {
            return
        }

        htmlString = """
        <!doctype html>
        <meta charset="utf-8">
        <meta name="viewport" content="height=device-height, initial-scale=1.0, user-scalable=no, minimum-scale=1.0, maximum-scale=1.0">
        <style>
            code {
                white-space: pre-wrap;
                overflow: auto;
            }
        </style>
        <pre><code>\(text)</code></pre>
        """
    }
}
