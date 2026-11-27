//
//  EffectViewerStageShaders.metal
//  RagnarokOffline
//
//  Created by Leon Li on 2026/11/26.
//

#include <metal_stdlib>
using namespace metal;

struct EffectViewerBackdropUniforms {
    float3 centerColor;
    float3 edgeColor;
};

struct EffectViewerBackdropOut {
    float4 position [[position]];
    float2 ndc;
};

vertex EffectViewerBackdropOut effectViewerBackdropVertex(uint vertexID [[vertex_id]]) {
    float2 positions[3] = {
        float2(-1.0, -1.0),
        float2( 3.0, -1.0),
        float2(-1.0,  3.0)
    };
    EffectViewerBackdropOut out;
    out.position = float4(positions[vertexID], 0.0, 1.0);
    out.ndc = positions[vertexID];
    return out;
}

fragment float4 effectViewerBackdropFragment(
    EffectViewerBackdropOut in [[stage_in]],
    constant EffectViewerBackdropUniforms &uniforms [[buffer(0)]]
) {
    float t = smoothstep(0.0, 1.2, length(in.ndc));
    float3 color = mix(uniforms.centerColor, uniforms.edgeColor, t);
    return float4(color, 1.0);
}

struct EffectViewerGridUniforms {
    float4x4 viewProjectionMatrix;
};

struct EffectViewerGridOut {
    float4 position [[position]];
    float2 worldXZ;
};

vertex EffectViewerGridOut effectViewerGridVertex(
    uint vertexID [[vertex_id]],
    constant EffectViewerGridUniforms &uniforms [[buffer(0)]]
) {
    float2 corners[4] = {
        float2(-32.0, -32.0),
        float2( 32.0, -32.0),
        float2(-32.0,  32.0),
        float2( 32.0,  32.0)
    };
    float2 xz = corners[vertexID];
    EffectViewerGridOut out;
    out.position = uniforms.viewProjectionMatrix * float4(xz.x, 0.0, xz.y, 1.0);
    out.worldXZ = xz;
    return out;
}

fragment float4 effectViewerGridFragment(EffectViewerGridOut in [[stage_in]]) {
    float2 coord = in.worldXZ;
    float2 minorDeriv = fwidth(coord);
    float2 minorGrid = abs(fract(coord - 0.5) - 0.5) / max(minorDeriv, float2(1e-4));
    float minorLine = 1.0 - min(min(minorGrid.x, minorGrid.y), 1.0);

    float2 majorCoord = coord / 5.0;
    float2 majorDeriv = fwidth(majorCoord);
    float2 majorGrid = abs(fract(majorCoord - 0.5) - 0.5) / max(majorDeriv, float2(1e-4));
    float majorLine = 1.0 - min(min(majorGrid.x, majorGrid.y), 1.0);

    float axisX = 1.0 - min(abs(coord.y) / max(minorDeriv.y, 1e-4), 1.0);
    float axisZ = 1.0 - min(abs(coord.x) / max(minorDeriv.x, 1e-4), 1.0);
    float axisLine = max(axisX, axisZ);

    float dist = length(coord);
    float fade = 1.0 - smoothstep(12.0, 28.0, dist);

    float alpha = max(minorLine * 0.12, majorLine * 0.24);
    alpha = max(alpha, axisLine * 0.30);
    alpha *= fade;

    if (alpha <= 0.001) {
        discard_fragment();
    }

    float3 color = float3(0.72, 0.76, 0.84);
    if (axisX > axisZ && axisX > 0.1) {
        color = mix(color, float3(0.75, 0.40, 0.42), 0.45);
    } else if (axisZ > 0.1) {
        color = mix(color, float3(0.42, 0.58, 0.80), 0.45);
    }

    return float4(color, alpha);
}
