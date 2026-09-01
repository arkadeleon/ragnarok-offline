//
//  TileShaders.metal
//  RagnarokShaders
//
//  Created by Leon Li on 2026/3/23.
//

#include <metal_stdlib>
using namespace metal;

#include "TileShaderTypes.h"

typedef struct {
    float4 position [[position]];
    float fogDepth;
} RasterizerData;

vertex RasterizerData
tileVertexShader(const device TileVertex *vertices [[buffer(0)]],
                 unsigned int vertexIndex [[vertex_id]],
                 constant TileVertexUniforms &uniforms [[buffer(1)]])
{
    TileVertex in = vertices[vertexIndex];

    float4 viewPosition = uniforms.viewMatrix * uniforms.modelMatrix * float4(in.position, 1.0);

    RasterizerData out;
    out.position = uniforms.projectionMatrix * viewPosition;
    out.fogDepth = -viewPosition.z;
    return out;
}

fragment float4
tileFragmentShader(RasterizerData in [[stage_in]],
                   constant TileFragmentUniforms &uniforms [[buffer(0)]])
{
    float4 color = uniforms.color;

    if (uniforms.fogUse) {
        float fogAmount = smoothstep(uniforms.fogNear, uniforms.fogFar, in.fogDepth);
        color.rgb = mix(color.rgb, uniforms.fogColor, fogAmount);
    }

    return color;
}
