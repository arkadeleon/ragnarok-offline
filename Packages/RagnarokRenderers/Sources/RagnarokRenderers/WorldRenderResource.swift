//
//  WorldRenderResource.swift
//  RagnarokRenderers
//
//  Created by Leon Li on 2026/7/14.
//

import Metal
import RagnarokRenderAssets

public class WorldRenderResource {
    let groundResource: GroundRenderResource
    let waterResource: WaterRenderResource
    let modelResources: [RSMModelRenderResource]

    public init(device: any MTLDevice, asset: WorldAsset) {
        groundResource = GroundRenderResource(device: device, asset: asset.ground, light: asset.light)
        waterResource = WaterRenderResource(device: device, asset: asset.water, light: asset.light)
        modelResources = asset.modelGroups.map { modelGroup in
            RSMModelRenderResource(
                device: device,
                prototype: modelGroup.prototype,
                instances: modelGroup.instances,
                light: asset.light
            )
        }
    }
}
