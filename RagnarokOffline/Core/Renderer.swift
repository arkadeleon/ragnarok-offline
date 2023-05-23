//
//  Renderer.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/5/23.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import MetalKit

protocol Renderer: MTKViewDelegate {
    var device: MTLDevice { get }
}
