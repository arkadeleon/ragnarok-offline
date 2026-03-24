//
//  ShadersLibrary.swift
//  RagnarokRenderers
//
//  Created by Leon Li on 2026/3/23.
//

import Metal
import RagnarokShaders

public func ragnarokShadersLibrary(device: any MTLDevice) -> (any MTLLibrary)? {
    RagnarokCreateShadersLibrary(device)
}
