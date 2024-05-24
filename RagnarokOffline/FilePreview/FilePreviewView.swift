//
//  FilePreviewView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/26.
//

import SwiftUI

struct FilePreviewView: View {
    var file: ObservableFile

    var body: some View {
        ZStack {
            switch file.file.info.type {
            case .text, .lua, .lub:
                TextFilePreviewView(file: file)
            case .image, .ebm, .pal:
                ImageFilePreviewView(file: file)
            case .audio:
                AudioFilePreviewView(file: file)
            case .act:
                ACTFilePreviewView(file: file)
            case .gat:
                GATFilePreviewView(file: file)
            case .gnd:
                GNDFilePreviewView(file: file)
            case .rsm:
                RSMFilePreviewView(file: file)
            case .rsw:
                RSWFilePreviewView(file: file)
            case .spr:
                SPRFilePreviewView(file: file)
            case .str:
                STRFilePreviewView(file: file)
            default:
                EmptyView()
            }
        }
    }
}

//#Preview {
//    FilePreviewView(file: <#T##File#>)
//}
