//
//  TextDocumentView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/4/7.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import SwiftUI

struct TextDocumentView: View {
    let file: File

    @State private var htmlString = ""

    var body: some View {
        WebView(htmlString: htmlString)
            .navigationTitle(file.name)
            .navigationBarTitleDisplayMode(.inline)
            .task {
                loadDocumentContents()
            }
    }

    private func loadDocumentContents() {
        guard let type = file.type, var data = file.contents() else {
            return
        }

        switch type {
        case .lub:
            let decompiler = LuaDecompiler()
            if let decompiledData = decompiler.decompileData(data) {
                data = decompiledData
            }
        default:
            break
        }

        var convertedString: NSString? = nil
        NSString.stringEncoding(for: data, convertedString: &convertedString, usedLossyConversion: nil)

        let text = convertedString ?? ""

        htmlString = """
        <!doctype html>
        <meta charset="utf-8">
        <meta name="viewport" content="height=device-height, initial-scale=1.0, user-scalable=no, minimum-scale=1.0, maximum-scale=1.0">
        <style>
            code {
                word-wrap: break-word;
                white-space: -moz-pre-wrap;
                white-space: pre-wrap;
            }
        </style>
        <pre><code>\(text)</code></pre>
        """
    }
}
