//
//  Effect2DShaders.metal
//  RagnarokShaders
//
//  Created by Leon Li on 2026/7/9.
//

#include <metal_stdlib>
using namespace metal;

#include "Effect2DShaderTypes.h"

typedef struct {
    float4 position [[position]];
    float2 textureCoordinate;
} Effect2DRasterizerData;

vertex Effect2DRasterizerData
effect2DVertexShader(const device Effect2DVertex *vertices [[buffer(0)]],
                     unsigned int vertexIndex [[vertex_id]],
                     constant Effect2DVertexUniforms &uniforms [[buffer(1)]])
{
    Effect2DVertex in = vertices[vertexIndex];

    float3 cameraRight = float3(uniforms.viewMatrix[0][0], uniforms.viewMatrix[1][0], uniforms.viewMatrix[2][0]);
    float3 cameraUp = float3(uniforms.viewMatrix[0][1], uniforms.viewMatrix[1][1], uniforms.viewMatrix[2][1]);

    const float spriteRatio = 1.0 / 35.0;
    float4 rotatedPosition = uniforms.rotationMatrix * float4(in.position * uniforms.size * spriteRatio, 0.0, 1.0);
    rotatedPosition.xy += uniforms.offset * spriteRatio;
    float3 worldPosition = uniforms.worldPosition
        + cameraRight * rotatedPosition.x
        + cameraUp * rotatedPosition.y;

    float4 clipPosition = uniforms.projectionMatrix * uniforms.viewMatrix * float4(worldPosition, 1.0);
    clipPosition.z -= uniforms.zIndex * 0.001 * clipPosition.w;

    Effect2DRasterizerData out;
    out.position = clipPosition;
    out.textureCoordinate = in.textureCoordinate;
    return out;
}

fragment float4
effect2DFragmentShader(Effect2DRasterizerData in [[stage_in]],
                       constant Effect2DFragmentUniforms &uniforms [[buffer(0)]],
                       texture2d<float> colorTexture [[texture(0)]])
{
    if (uniforms.color.a <= 0.0) {
        discard_fragment();
    }

    constexpr sampler textureSampler(mag_filter::linear, min_filter::linear);
    float4 color = colorTexture.sample(textureSampler, in.textureCoordinate);
    if (color.a < 0.01) {
        discard_fragment();
    }
    if (color.r < 0.01 && color.g < 0.01 && color.b < 0.01) {
        discard_fragment();
    }

    return color * uniforms.color;
}
