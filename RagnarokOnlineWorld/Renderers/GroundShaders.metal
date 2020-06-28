//
//  GroundShaders.metal
//  RagnarokOnlineWorld
//
//  Created by Li, Junlin on 2020/6/23.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#include "GroundShaderTypes.h"

typedef struct {
    float4 position [[position]];
    float2 textureCoordinate;
} GroundRasterizerData;

vertex GroundRasterizerData
groundVertexShader(const device GroundVertex *vertices [[buffer(0)]],
                   unsigned int vertexIndex [[vertex_id]],
                   constant GroundVertexUniforms &uniforms [[buffer(1)]])
{
    GroundVertex in = vertices[vertexIndex];

    GroundRasterizerData out;
    out.position = uniforms.projectionMat * float4(in.position, 1.0);
    return out;
}

fragment float4
groundFragmentShader(GroundRasterizerData in [[stage_in]],
                     constant GroundFragmentUniforms &uniforms [[buffer(0)]],
                     texture2d<float> texture [[texture(0)]])
{
    return float4(1.0, 1.0, 1.0, 1.0);
}
