//
//  SkyboxShaders.metal
//  RagnarokShaders
//
//  Created by Leon Li on 2026/4/8.
//

#include <metal_stdlib>
using namespace metal;

#include "SkyboxShaderTypes.h"

struct SkyboxRasterizerData {
    float4 position [[position]];
    float2 clipPosition;
};

vertex SkyboxRasterizerData
skyboxVertexShader(uint vertexIndex [[vertex_id]])
{
    float2 positions[4] = {
        float2(-1.0,  1.0),
        float2( 1.0,  1.0),
        float2(-1.0, -1.0),
        float2( 1.0, -1.0),
    };

    float2 pos = positions[vertexIndex];

    SkyboxRasterizerData out;
    out.position = float4(pos, 1.0, 1.0);
    out.clipPosition = pos;
    return out;
}

fragment float4
skyboxFragmentShader(SkyboxRasterizerData in [[stage_in]],
                     constant SkyboxUniforms &uniforms [[buffer(0)]])
{
    constexpr float pi = 3.14159265358979323846264;
    float3 top     = uniforms.topColor.xyz;
    float3 horizon = uniforms.horizonColor.xyz;
    float3 bottom  = uniforms.bottomColor.xyz;
    float3 sphereCenter = uniforms.sphereCenterAndRadius.xyz;
    float sphereRadius = uniforms.sphereCenterAndRadius.w;
    float3 cameraPosition = uniforms.cameraPosition.xyz;

    float4 farWorldHomogeneous = uniforms.inverseViewProjectionMatrix * float4(in.clipPosition, 1.0, 1.0);
    float3 farWorldPosition = farWorldHomogeneous.xyz / farWorldHomogeneous.w;
    float3 rayDirection = normalize(farWorldPosition - cameraPosition);

    float3 offset = cameraPosition - sphereCenter;
    float b = dot(offset, rayDirection);
    float c = dot(offset, offset) - sphereRadius * sphereRadius;
    float discriminant = max(b * b - c, 0.0);
    float t = -b + sqrt(discriminant);
    float3 spherePoint = cameraPosition + rayDirection * max(t, 0.0);
    float3 sphereDirection = normalize(spherePoint - sphereCenter);
    float v = acos(clamp(sphereDirection.y, -1.0, 1.0)) / pi;

    float3 color;
    if (v < 0.5) {
        color = mix(top, horizon, v * 2.0);
    } else {
        color = mix(horizon, bottom, (v - 0.5) * 2.0);
    }

    return float4(color, 1.0);
}
