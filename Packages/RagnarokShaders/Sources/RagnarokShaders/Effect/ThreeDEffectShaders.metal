//
//  ThreeDEffectShaders.metal
//  RagnarokShaders
//
//  Created by Leon Li on 2026/6/29.
//

#include <metal_stdlib>
using namespace metal;

#include "ThreeDEffectShaderTypes.h"

typedef struct {
    float4 position [[position]];
    float2 textureCoordinate;
    float fogDepth;
} ThreeDEffectRasterizerData;

vertex ThreeDEffectRasterizerData
threeDEffectVertexShader(const device ThreeDEffectVertex *vertices [[buffer(0)]],
                         unsigned int vertexIndex [[vertex_id]],
                         constant ThreeDEffectVertexUniforms &uniforms [[buffer(1)]])
{
    ThreeDEffectVertex in = vertices[vertexIndex];

    float3 cameraRight = float3(uniforms.viewMatrix[0][0], uniforms.viewMatrix[1][0], uniforms.viewMatrix[2][0]);
    float3 cameraUp = float3(uniforms.viewMatrix[0][1], uniforms.viewMatrix[1][1], uniforms.viewMatrix[2][1]);
    float3 cameraBack = float3(uniforms.viewMatrix[0][2], uniforms.viewMatrix[1][2], uniforms.viewMatrix[2][2]);
    float3 cameraForward = -cameraBack;
    float3 viewTranslation = uniforms.viewMatrix[3].xyz;
    float3 cameraPosition = -(viewTranslation.x * cameraRight + viewTranslation.y * cameraUp + viewTranslation.z * cameraBack);

    const float spriteRatio = 1.0 / 35.0;
    float4 rotatedPosition = uniforms.rotationMatrix * float4(in.position * uniforms.size * spriteRatio, 0.0, 1.0);
    rotatedPosition.xy += uniforms.offset * spriteRatio;

    // worldPosition is (map x, map y, altitude); the model matrix maps it to render space.
    float3 p = uniforms.worldPosition;
    float3 anchorPosition = (uniforms.modelMatrix * float4(p.x, -p.z, p.y, 1.0)).xyz;
    float3 worldPosition = anchorPosition
        + cameraRight * rotatedPosition.x
        + cameraUp * rotatedPosition.y;

    float4 clipPosition = uniforms.projectionMatrix * uniforms.viewMatrix * float4(worldPosition, 1.0);

    // The billboard leans back toward the camera, so its upper part could
    // end up behind nearby ground or models and get cut off. To avoid that,
    // limit each vertex's depth to an upright plane half a cell in front of
    // the anchor. The half-cell offset is the same one the sprite shader
    // uses, so an effect and a sprite on the same spot get the same depth.
    float3 planeNormal = float3(cameraForward.x, 0.0, cameraForward.z);
    planeNormal = length(planeNormal) < 0.000001 ? cameraForward : normalize(planeNormal);
    float3 planePoint = anchorPosition - planeNormal * 0.5;
    float3 rayDirection = normalize(worldPosition - cameraPosition);
    float rayDistance = dot(planePoint - cameraPosition, planeNormal) / max(dot(planeNormal, rayDirection), 0.000001);
    float4 planeClipPosition = uniforms.projectionMatrix * uniforms.viewMatrix * float4(cameraPosition + rayDirection * rayDistance, 1.0);
    clipPosition.z = min(clipPosition.z, planeClipPosition.z * (clipPosition.w / max(planeClipPosition.w, 0.000001)));

    clipPosition.z -= uniforms.zIndex * 0.001 * clipPosition.w;

    ThreeDEffectRasterizerData out;
    out.position = clipPosition;
    out.textureCoordinate = in.textureCoordinate;
    out.fogDepth = -(uniforms.viewMatrix * float4(worldPosition, 1.0)).z;
    return out;
}

fragment float4
threeDEffectFragmentShader(ThreeDEffectRasterizerData in [[stage_in]],
                           constant ThreeDEffectFragmentUniforms &uniforms [[buffer(0)]],
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

    color = color * uniforms.color;

    if (uniforms.fogUse) {
        float fogAmount = smoothstep(uniforms.fogNear, uniforms.fogFar, in.fogDepth);
        color.rgb = mix(color.rgb, uniforms.fogColor, fogAmount);
    }

    return color;
}
