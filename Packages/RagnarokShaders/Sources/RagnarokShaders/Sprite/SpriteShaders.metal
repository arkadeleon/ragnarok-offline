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

    // spriteWorldPosition is (map x, map y, altitude); the model matrix places it.
    float3 p = uniforms.spriteWorldPosition.xyz;
    float3 basePos = (uniforms.modelMatrix * float4(p.x, -p.z, p.y, 1.0)).xyz;

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
        float2 viewportPoint = in.position.xy - uniforms.viewport.xy;
        float2 ndc = float2(viewportPoint.x / uniforms.viewport.z * 2.0 - 1.0,
                            1.0 - viewportPoint.y / uniforms.viewport.w * 2.0);

        // The frustum is off-axis on visionOS, so undo the projection's shear as well
        // as its scale.
        float3 rayView = float3((ndc.x + uniforms.projectionMatrix[2][0]) / uniforms.projectionMatrix[0][0],
                                (ndc.y + uniforms.projectionMatrix[2][1]) / uniforms.projectionMatrix[1][1],
                                -1.0);

        float3 cameraRight   = float3(uniforms.viewMatrix[0][0], uniforms.viewMatrix[1][0], uniforms.viewMatrix[2][0]);
        float3 cameraUp      = float3(uniforms.viewMatrix[0][1], uniforms.viewMatrix[1][1], uniforms.viewMatrix[2][1]);
        float3 cameraBack    = float3(uniforms.viewMatrix[0][2], uniforms.viewMatrix[1][2], uniforms.viewMatrix[2][2]);
        float3 cameraForward = -cameraBack;
        float3 rayWorld = cameraRight * rayView.x + cameraUp * rayView.y + cameraBack * rayView.z;

        float3 p = uniforms.spriteWorldPosition.xyz;
        float3 anchor = (uniforms.modelMatrix * float4(p.x, -p.z, p.y, 1.0)).xyz;
        float3 cameraPos = uniforms.cameraPosition.xyz;

        // The plane stands upright in the world, so drop the component of the view
        // direction along whichever way the model matrix points the world's up.
        float3 worldUp = normalize((uniforms.modelMatrix * float4(0.0, -1.0, 0.0, 0.0)).xyz);
        float3 planeNormal = cameraForward - worldUp * dot(cameraForward, worldUp);
        if (length(planeNormal) < 0.000001) {
            planeNormal = cameraForward;
        }
        planeNormal = normalize(planeNormal);

        // Place the plane half a cell in front of the anchor. Without this,
        // ground that rises right in front of the sprite would cover its lower body.
        float3 planePoint = anchor - planeNormal * 0.5;

        float denom = dot(planeNormal, rayWorld);
        if (abs(denom) > 0.000001) {
            float t = dot(planePoint - cameraPos, planeNormal) / denom;
            float4 hitClip = uniforms.projectionMatrix * uniforms.viewMatrix * float4(cameraPos + rayWorld * t, 1.0);
            out.depth = hitClip.z / max(hitClip.w, 0.000001);
        }
    }

    return out;
}
