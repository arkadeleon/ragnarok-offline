//
//  TextFilePreviewView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/24.
//

import SwiftUI
import Lua
import ROFileSystem

struct TextFilePreviewView: View {
    let file: File

    @State private var loadStatus: LoadStatus = .notYetLoaded
    @State private var htmlString = ""

    var body: some View {
        WebView(htmlString: htmlString, baseURL: nil)
            .overlay {
                if loadStatus == .loading {
                    ProgressView()
                }
            }
            .navigationTitle(file.name)
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await loadText()
            }
    }

    private func loadText() async {
        guard loadStatus == .notYetLoaded else {
            return
        }

        loadStatus = .loading

        guard let type = file.type, var data = file.contents() else {
            loadStatus = .failed
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

        guard let convertedString else {
            loadStatus = .failed
            return
        }

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
        <pre><code>\(convertedString)</code></pre>
        """

        loadStatus = .loaded
    }
}

//#Preview {
//    TextFilePreviewView(file: .regularFile(<#T##URL#>))
//}
