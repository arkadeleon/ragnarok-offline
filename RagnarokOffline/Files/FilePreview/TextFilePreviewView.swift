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
        AsyncContentView(load: loadTextFile) { text in
            HighlightTextView(text: text)
        }
    }

    nonisolated private func loadTextFile() async throws -> String {
        guard var data = await file.contents() else {
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

        return convertedString as String
    }
}

//#Preview {
//    TextFilePreviewView(file: <#T##File#>)
//}
