//
//  TextFilePreviewView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/24.
//

import RagnarokLua
import SwiftUI

struct TextFilePreviewView: View {
    var file: File

    var body: some View {
        AsyncContentView {
            try await loadTextFile()
        } content: { text in
            HighlightTextView(text: text)
                .ignoresSafeArea()
        }
    }

    private func loadTextFile() async throws -> String {
        var data = try await file.contents()

        switch file.utType {
        case .lub:
            let decompiler = LuaDecompiler()
            data = try decompiler.decompileData(data)
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
