//
//  Ground.metal
//  RagnarokReality
//
//  Created by Leon Li on 2025/10/31.
//

#include <metal_stdlib>
#include <RealityKit/RealityKit.h>

using namespace metal;

[[visible]]
void groundSurface(realitykit::surface_parameters params) {
    constexpr sampler textureSampler(
        coord::normalized,
        address::clamp_to_edge,
        filter::linear
    );

    float2 uv0 = params.geometry().uv0();
    float2 uv1 = params.geometry().uv1();

    half4 baseColor = params.textures().base_color().sample(textureSampler, uv0);

    half3 shadedColor = baseColor.rgb;
    if (params.uniforms().custom_parameter().x == 1.0) {
        half4 lightmap = params.textures().custom().sample(textureSampler, uv1);
        half3 lightColor = clamp(lightmap.rgb, half3(0.0), half3(1.0));
        half lightAlpha = lightmap.a;

        shadedColor = baseColor.rgb * lightAlpha + lightColor;
    }

    params.surface().set_base_color(shadedColor);
    params.surface().set_emissive_color(shadedColor);
    params.surface().set_opacity(1.0h);
}
