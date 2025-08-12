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
        AsyncContentView {
            try await loadTextFile()
        } content: { text in
            HighlightTextView(text: text)
        }
    }

    private func loadTextFile() async throws -> String {
        var data = try await file.contents()

        switch file.utType {
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
            throw FileError.stringConversionFailed
        }

        return convertedString as String
    }
}

//#Preview {
//    TextFilePreviewView(file: <#T##File#>)
//}
