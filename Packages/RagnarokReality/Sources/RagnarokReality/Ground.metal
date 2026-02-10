//
//  Ground.metal
//  RagnarokReality
//
//  Created by Leon Li on 2025/10/31.
//

#include <metal_stdlib>
#include <RealityKit/RealityKit.h>

using namespace metal;

constant bool kUseLightmap [[function_constant(0)]];
constant float3 kLightAmbient [[function_constant(1)]];
constant float3 kLightDiffuse [[function_constant(2)]];
constant float kLightOpacity [[function_constant(3)]];

static inline half3 srgbToLinear(half3 color) {
    half3 c = clamp(color, half3(0.0h), half3(1.0h));
    half3 lo = c / 12.92h;
    half3 hi = pow((c + 0.055h) / 1.055h, half3(2.4h));
    return select(lo, hi, c > half3(0.04045h));
}

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

    if (uv2.x != 0.0 || uv2.y != 0.0) {
        half4 tileColor = params.textures().emissive_color().sample(textureSampler, uv2.xy);
        textureColor *= tileColor;
    }

    float lightWeight = 1.0;
    float3 ambient = kLightAmbient * kLightOpacity;
    float3 diffuse = kLightDiffuse * lightWeight;

    if (kUseLightmap) {
        half4 lightmap = params.textures().custom().sample(textureSampler, uv1);
        float3 lightColor = clamp((ambient + diffuse) * lightmap.a, 0.0, 1.0);
        half3 srgbColor = textureColor.rgb * half3(lightColor) + clamp(lightmap.rgb, 0.0h, 1.0h);
        half3 linearColor = srgbToLinear(clamp(srgbColor, 0.0h, 1.0h));
        params.surface().set_base_color(linearColor);
        params.surface().set_emissive_color(linearColor);
    } else {
        float3 lightColor = clamp(ambient + diffuse, 0.0, 1.0);
        half3 srgbColor = textureColor.rgb * half3(lightColor);
        half3 linearColor = srgbToLinear(clamp(srgbColor, 0.0h, 1.0h));
        params.surface().set_base_color(linearColor);
        params.surface().set_emissive_color(linearColor);
    }
    params.surface().set_opacity(textureColor.a);
}
