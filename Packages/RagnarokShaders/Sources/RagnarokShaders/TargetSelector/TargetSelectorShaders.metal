//
//  TargetSelectorShaders.metal
//  RagnarokShaders
//
//  Created by Leon Li on 2026/10/13.
//

#include <metal_stdlib>
using namespace metal;

#include "TargetSelectorShaderTypes.h"

typedef struct {
    float4 position [[position]];
    float4 color;
} RasterizerData;

vertex RasterizerData
targetSelectorVertexShader(const device TargetSelectorVertex *vertices [[buffer(0)]],
                           unsigned int vertexIndex [[vertex_id]],
                           constant TargetSelectorVertexUniforms &uniforms [[buffer(1)]])
{
    TargetSelectorVertex in = vertices[vertexIndex];

    float3 cameraRight = float3(uniforms.viewMatrix[0][0], uniforms.viewMatrix[1][0], uniforms.viewMatrix[2][0]);
    float3 cameraUp    = float3(uniforms.viewMatrix[0][1], uniforms.viewMatrix[1][1], uniforms.viewMatrix[2][1]);

    float3 p = uniforms.worldPosition;
    float3 anchor = (uniforms.modelMatrix * float4(p.x, -p.z, p.y, 1.0)).xyz;

    // The marker always faces the camera, like a sprite.
    float2 position = (in.position + uniforms.offset) / 32.0;
    float3 worldPosition = anchor + cameraRight * position.x + cameraUp * position.y;

    RasterizerData out;
    out.position = uniforms.projectionMatrix * uniforms.viewMatrix * float4(worldPosition, 1.0);
    out.color = in.color;
    return out;
}

fragment float4
targetSelectorFragmentShader(RasterizerData in [[stage_in]])
{
    return in.color;
}
