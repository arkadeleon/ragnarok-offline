//
//  FileNode.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/4/18.
//

import Foundation
import ROFileFormats

enum FileNode {
    case directory(URL)
    case regularFile(URL)
    case grf(GRFReference)
    case grfDirectory(GRFReference, GRFPath)
    case grfEntry(GRFReference, GRFPath)
}
