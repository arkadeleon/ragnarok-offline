//
//  TextFilePreviewView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/24.
//

import SwiftUI
import Lua
import ROFileSystem

enum TextFilePreviewError: Error {
    case invalidTextFile
}

struct TextFilePreviewView: View {
    let file: File

    @State private var status: AsyncContentStatus<String> = .notYetLoaded

    var body: some View {
        AsyncContentView(status: status) { htmlString in
            WebView(htmlString: htmlString, baseURL: nil)
        }
        .navigationTitle(file.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadText()
        }
    }

    private func loadText() async {
        guard case .notYetLoaded = status else {
            return
        }

        status = .loading

        guard let type = file.type, var data = file.contents() else {
            status = .failed(TextFilePreviewError.invalidTextFile)
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

        if let convertedString {
            let htmlString = """
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
            <pre><code>\(convertedString)</code></pre>
            """
            status = .loaded(htmlString)
        } else {
            status = .failed(TextFilePreviewError.invalidTextFile)
        }
    }
}

//#Preview {
//    TextFilePreviewView(file: <#T##File#>)
//}
