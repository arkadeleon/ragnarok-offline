//
//  EffectPrimitiveShaders.metal
//  RagnarokShaders
//
//  Created by Leon Li on 2026/11/24.
//

#include <metal_stdlib>
using namespace metal;

#include "EffectPrimitiveShaderTypes.h"

typedef struct {
    float4 position [[position]];
    float2 textureCoordinate;
    float4 color;
    float fogDepth;
} EffectPrimitiveRasterizerData;

vertex EffectPrimitiveRasterizerData
effectPrimitiveVertexShader(const device EffectPrimitiveVertex *vertices [[buffer(0)]],
                            unsigned int vertexIndex [[vertex_id]],
                            constant EffectPrimitiveVertexUniforms &uniforms [[buffer(1)]])
{
    EffectPrimitiveVertex in = vertices[vertexIndex];
    EffectPrimitiveRasterizerData out;

    float4 viewPosition;
    if (uniforms.renderMode == 1) {
        // Billboard3D: expand billboardOffset along camera-aligned world right/up axes.
        float3 cameraRight = float3(uniforms.viewMatrix[0][0], uniforms.viewMatrix[1][0], uniforms.viewMatrix[2][0]);
        float3 cameraUp = float3(uniforms.viewMatrix[0][1], uniforms.viewMatrix[1][1], uniforms.viewMatrix[2][1]);
        float3 anchor = (uniforms.modelMatrix * float4(in.position, 1.0)).xyz;
        float3 worldPosition = anchor + cameraRight * in.billboardOffset.x + cameraUp * in.billboardOffset.y;
        viewPosition = uniforms.viewMatrix * float4(worldPosition, 1.0);
    } else {
        // World3D: vertices are already placed in world space.
        viewPosition = uniforms.viewMatrix * uniforms.modelMatrix * float4(in.position, 1.0);
    }

    // Apply depthBias in view space so it remains compatible with Reversed-Z projections.
    viewPosition.z += uniforms.depthBias;

    out.position = uniforms.projectionMatrix * viewPosition;
    out.textureCoordinate = in.textureCoordinate;
    out.color = in.color;
    out.fogDepth = -viewPosition.z;
    return out;
}

fragment float4
effectPrimitiveFragmentShader(EffectPrimitiveRasterizerData in [[stage_in]],
                              constant EffectPrimitiveFragmentUniforms &uniforms [[buffer(0)]],
                              texture2d<float> colorTexture [[texture(0)]])
{
    constexpr sampler textureSampler(mag_filter::linear, min_filter::linear, address::repeat);
    float4 color = colorTexture.sample(textureSampler, in.textureCoordinate) * in.color;
    if (color.a <= uniforms.alphaTestThreshold) {
        discard_fragment();
    }

    if (uniforms.fogUse != 0) {
        float fogAmount = smoothstep(uniforms.fogNear, uniforms.fogFar, in.fogDepth);
        color.rgb = mix(color.rgb, uniforms.fogColor, fogAmount);
    }

    return color;
}
