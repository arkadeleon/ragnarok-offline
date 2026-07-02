//
//  SPREffectShaders.metal
//  RagnarokShaders
//
//  Created by Leon Li on 2026/7/2.
//

#include <metal_stdlib>
using namespace metal;

#include "SPREffectShaderTypes.h"

typedef struct {
    float4 position [[position]];
    float2 textureCoordinate;
} SPREffectRasterizerData;

vertex SPREffectRasterizerData
sprEffectVertexShader(const device SPREffectVertex *vertices [[buffer(0)]],
                      unsigned int vertexIndex [[vertex_id]],
                      constant SPREffectVertexUniforms &uniforms [[buffer(1)]])
{
    SPREffectVertex in = vertices[vertexIndex];

    float3 cameraRight = float3(uniforms.viewMatrix[0][0], uniforms.viewMatrix[1][0], uniforms.viewMatrix[2][0]);
    float3 cameraUp = float3(uniforms.viewMatrix[0][1], uniforms.viewMatrix[1][1], uniforms.viewMatrix[2][1]);

    const float spriteRatio = 1.0 / 35.0;
    float2 scaledPosition = in.position * uniforms.size * spriteRatio;
    float3 worldPosition = uniforms.worldPosition
        + cameraRight * scaledPosition.x
        + cameraUp * scaledPosition.y;

    float4 clipPosition = uniforms.projectionMatrix * uniforms.viewMatrix * float4(worldPosition, 1.0);
    clipPosition.z -= uniforms.zIndex * 0.001 * clipPosition.w;

    SPREffectRasterizerData out;
    out.position = clipPosition;
    out.textureCoordinate = in.textureCoordinate;
    return out;
}

fragment float4
sprEffectFragmentShader(SPREffectRasterizerData in [[stage_in]],
                        texture2d<float> colorTexture [[texture(0)]])
{
    constexpr sampler textureSampler(mag_filter::linear, min_filter::linear);
    float4 color = colorTexture.sample(textureSampler, in.textureCoordinate);
    if (color.a < 0.01) {
        discard_fragment();
    }
    return color;
}

