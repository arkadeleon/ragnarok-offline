//
//  FilePreviewView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/26.
//

import SwiftUI
import ROFileSystem

struct FilePreviewView: View {
    let file: File

    var body: some View {
        ZStack {
            if let type = file.type {
                switch type {
                case let type where type.conforms(to: .text) || type == .lua || type == .lub:
                    TextFilePreviewView(file: file)
                case let type where type.conforms(to: .image) || type == .ebm || type == .pal:
                    ImageFilePreviewView(file: file)
                case let type where type.conforms(to: .audio):
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
            } else {
                EmptyView()
            }
        }
    }
}

//#Preview {
//    FilePreviewView(file: <#T##File#>)
//}
