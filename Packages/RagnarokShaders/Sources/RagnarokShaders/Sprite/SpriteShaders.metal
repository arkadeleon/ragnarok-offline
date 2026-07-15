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

    // spriteWorldPosition is (grid x, grid y, altitude); convert to render space.
    float3 p = uniforms.spriteWorldPosition.xyz;
    float3 basePos = float3(p.x + 0.5, p.z, -p.y - 0.5);

    // 1 world unit = 32 pixels.
    const float pixelRatio = 1.0 / 32.0;
    float3 worldPos = basePos
        + cameraRight * in.position.x * pixelRatio
        + cameraUp    * in.position.y * pixelRatio;

    float4 clipPos = uniforms.projectionMatrix * uniforms.viewMatrix * float4(worldPos, 1.0);

    RasterizerData out;
    out.position = clipPos;
    out.textureCoordinate = in.textureCoordinate;
    out.color = in.color;
    return out;
}

typedef struct {
    float4 color [[color(0)]];
    float depth [[depth(any)]];
} SpriteFragmentOut;

fragment SpriteFragmentOut
spriteFragmentShader(RasterizerData in [[stage_in]],
                     constant SpriteVertexUniforms &uniforms [[buffer(0)]],
                     texture2d<float> colorTexture [[texture(0)]])
{
    constexpr sampler textureSampler(mag_filter::linear, min_filter::linear);
    float4 color = colorTexture.sample(textureSampler, in.textureCoordinate);
    if (color.a < 0.01) {
        discard_fragment();
    }

    SpriteFragmentOut out;
    out.color = color * in.color;
    out.depth = in.position.z;

    if (uniforms.cameraPosition.w != 0.0) {
        // Depth of the vertical plane through the anchor along this pixel's ray.
        // It only depends on the pixel coordinate and per-sprite uniforms, so
        // every layer of a sprite resolves to the same depth and draw order
        // decides the layering.
        float2 ndc = float2(in.position.x / uniforms.framebufferSize.x * 2.0 - 1.0,
                            1.0 - in.position.y / uniforms.framebufferSize.y * 2.0);
        float3 rayView = float3(ndc.x / uniforms.projectionMatrix[0][0],
                                ndc.y / uniforms.projectionMatrix[1][1],
                                1.0);

        float3 cameraRight   = float3(uniforms.viewMatrix[0][0], uniforms.viewMatrix[1][0], uniforms.viewMatrix[2][0]);
        float3 cameraUp      = float3(uniforms.viewMatrix[0][1], uniforms.viewMatrix[1][1], uniforms.viewMatrix[2][1]);
        float3 cameraForward = float3(uniforms.viewMatrix[0][2], uniforms.viewMatrix[1][2], uniforms.viewMatrix[2][2]);
        float3 rayWorld = cameraRight * rayView.x + cameraUp * rayView.y + cameraForward * rayView.z;

        float3 p = uniforms.spriteWorldPosition.xyz;
        float3 anchor = float3(p.x + 0.5, p.z, -p.y - 0.5);
        float3 cameraPos = uniforms.cameraPosition.xyz;

        float3 planeNormal = float3(cameraForward.x, 0.0, cameraForward.z);
        if (length(planeNormal) < 0.000001) {
            planeNormal = cameraForward;
        }

        float denom = dot(planeNormal, rayWorld);
        if (abs(denom) > 0.000001) {
            float t = dot(anchor - cameraPos, planeNormal) / denom;
            float4 hitClip = uniforms.projectionMatrix * uniforms.viewMatrix * float4(cameraPos + rayWorld * t, 1.0);
            out.depth = hitClip.z / max(hitClip.w, 0.000001);
        }
    }

    return out;
}
