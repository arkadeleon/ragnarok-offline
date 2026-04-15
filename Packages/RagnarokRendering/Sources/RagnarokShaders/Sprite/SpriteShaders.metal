//
//  SpriteShaders.metal
//  RagnarokShaders
//
//  Created by Leon Li on 2026/3/23.
//

#include <metal_stdlib>
using namespace metal;

#include "SpriteShaderTypes.h"

typedef struct {
    float4 position [[position]];
    float2 textureCoordinate;
    float4 color;
} RasterizerData;

vertex RasterizerData
spriteVertexShader(const device SpriteVertex *vertices [[buffer(0)]],
                   unsigned int vertexIndex [[vertex_id]],
                   constant SpriteVertexUniforms &uniforms [[buffer(1)]])
{
    SpriteVertex in = vertices[vertexIndex];

    float3 cameraRight = float3(uniforms.viewMatrix[0][0], uniforms.viewMatrix[1][0], uniforms.viewMatrix[2][0]);
    float3 cameraUp    = float3(uniforms.viewMatrix[0][1], uniforms.viewMatrix[1][1], uniforms.viewMatrix[2][1]);

    // 1 world unit = 32 pixels.
    const float pixelRatio = 1.0 / 32.0;
    float3 worldPos = uniforms.spriteWorldPosition.xyz
        + cameraRight * in.position.x * pixelRatio
        + cameraUp    * in.position.y * pixelRatio;

    float4 clipPos = uniforms.projectionMatrix * uniforms.viewMatrix * float4(worldPos, 1.0);

    // Depth bias to prevent z-fighting with ground geometry at the same depth.
    clipPos.z -= 0.001 * clipPos.w;

    RasterizerData out;
    out.position = clipPos;
    out.textureCoordinate = in.textureCoordinate;
    out.color = in.color;
    return out;
}

fragment float4
spriteFragmentShader(RasterizerData in [[stage_in]],
                     texture2d<float> colorTexture [[texture(0)]])
{
    constexpr sampler textureSampler(mag_filter::linear, min_filter::linear);
    float4 color = colorTexture.sample(textureSampler, in.textureCoordinate);
    if (color.a < 0.01) {
        discard_fragment();
    }
    return color * in.color;
}
