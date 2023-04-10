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
    @State private var encoding: Encoding = .ascii

    var body: some View {
        WebView(htmlString: htmlString)
            .navigationTitle(previewItem.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        ForEach(Encoding.allCases, id: \.name) { encoding in
                            Button {
                                self.encoding = encoding
                                loadPreviewItem()
                            } label: {
                                HStack {
                                    Text(encoding.name)
                                    if encoding == self.encoding {
                                        Spacer()
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        Text(encoding.name)
                    }
                }
            }
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

        let text = String(data: data, encoding: encoding.swiftStringEncoding) ?? ""

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
