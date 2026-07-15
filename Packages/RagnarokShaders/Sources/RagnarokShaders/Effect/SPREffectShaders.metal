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
    float3 cameraForward = float3(uniforms.viewMatrix[0][2], uniforms.viewMatrix[1][2], uniforms.viewMatrix[2][2]);
    float3 viewTranslation = uniforms.viewMatrix[3].xyz;
    float3 cameraPosition = -(viewTranslation.x * cameraRight + viewTranslation.y * cameraUp + viewTranslation.z * cameraForward);

    const float spriteRatio = 1.0 / 35.0;
    float2 scaledPosition = in.position * uniforms.size * spriteRatio;

    // worldPosition is (map x, map y, altitude); the model matrix maps it to render space.
    float3 p = uniforms.worldPosition;
    float3 anchorPosition = (uniforms.modelMatrix * float4(p.x, -p.z, p.y, 1.0)).xyz;
    float3 worldPosition = anchorPosition
        + cameraRight * scaledPosition.x
        + cameraUp * scaledPosition.y;

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

