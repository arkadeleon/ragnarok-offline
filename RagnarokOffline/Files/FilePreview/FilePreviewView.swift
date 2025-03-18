//
//  FilePreviewView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/26.
//

import SwiftUI

enum FilePreviewError: Error {
    case invalidTextFile
    case invalidImageFile
    case invalidAudioFile
    case invalidACTFile
    case invalidGATFile
    case invalidGNDFile
    case invalidRSMFile
    case invalidRSWFile
    case invalidSPRFile
    case invalidSTRFile
}

struct FilePreviewView: View {
    var file: File

    var body: some View {
        ZStack {
            if let utType = file.utType {
                switch utType {
                case let utType where utType.conforms(to: .text):
                    TextFilePreviewView(file: file)
                case .lua, .lub:
                    TextFilePreviewView(file: file)
                case let utType where utType.conforms(to: .image):
                    ImageFilePreviewView(file: file)
                case .ebm, .pal:
                    ImageFilePreviewView(file: file)
                case let utType where utType.conforms(to: .audio):
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
}

//#Preview {
//    FilePreviewView(file: <#T##File#>)
//}
