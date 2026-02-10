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
    float4 uv2 = params.geometry().uv2();

    half4 textureColor = params.textures().base_color().sample(textureSampler, uv0);
    if (textureColor.a == 0.0h) {
        params.surface().set_base_color(half3(0.0h));
        params.surface().set_emissive_color(half3(0.0h));
        params.surface().set_opacity(0.0h);
        return;
    }

    if (params.uniforms().custom_parameter().y == 1.0 && (uv2.x != 0.0 || uv2.y != 0.0)) {
        half4 tileColor = params.textures().emissive_color().sample(textureSampler, uv2.xy);
        textureColor *= tileColor;
    }

    half3 shadedColor = textureColor.rgb;
    if (params.uniforms().custom_parameter().x == 1.0) {
        half4 lightmap = params.textures().custom().sample(textureSampler, uv1);
        half3 lightColor = clamp(lightmap.rgb, half3(0.0h), half3(1.0h));
        half lightAlpha = clamp(lightmap.a, 0.0h, 1.0h);

        shadedColor = textureColor.rgb * lightAlpha + lightColor;
    }

    params.surface().set_base_color(shadedColor);
    params.surface().set_emissive_color(shadedColor);
    params.surface().set_opacity(textureColor.a);
}
