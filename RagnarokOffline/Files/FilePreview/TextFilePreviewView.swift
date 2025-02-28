//
//  TextFilePreviewView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/24.
//

import Lua
import SwiftUI

struct TextFilePreviewView: View {
    var file: File

    var body: some View {
        AsyncContentView(load: loadTextFile) { htmlString in
            WebView(htmlString: htmlString, baseURL: nil)
        }
    }

    nonisolated private func loadTextFile() async throws -> String {
        guard var data = file.contents() else {
            throw FilePreviewError.invalidTextFile
        }

        switch file.type {
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

        guard let convertedString else {
            throw FilePreviewError.invalidTextFile
        }

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
        return htmlString
    }
}

//#Preview {
//    TextFilePreviewView(file: <#T##File#>)
//}
