//
//  SurfaceShaders.swift
//  RagnarokRealitySurfaceShaders
//
//  Created by Leon Li on 2026/3/6.
//

import Metal
import RealityKit

public struct SurfaceShaders {
    private static let library: MTLLibrary = {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError()
        }

        guard let library = try? device.makeDefaultLibrary(bundle: .module) else {
            fatalError()
        }

        return library
    }()

    public static func groundSurfaceShader(constantValues: MTLFunctionConstantValues) -> CustomMaterial.SurfaceShader {
        CustomMaterial.SurfaceShader(
            named: "groundSurfaceShader",
            in: library,
            constantValues: constantValues
        )
    }

    public static func modelSurfaceShader(constantValues: MTLFunctionConstantValues) -> CustomMaterial.SurfaceShader {
        CustomMaterial.SurfaceShader(
            named: "modelSurfaceShader",
            in: library,
            constantValues: constantValues
        )
    }
}
