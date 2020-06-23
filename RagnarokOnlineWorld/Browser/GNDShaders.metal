//
//  GNDShaders.metal
//  RagnarokOnlineWorld
//
//  Created by Li, Junlin on 2020/6/23.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#include "GNDVertex.h"

typedef struct {
    float4 position [[position]];
    float2 textureCoordinate;
} GNDVertexOut;

vertex GNDVertexOut
gndVertexShader(const device GNDVertex *vertices [[buffer(0)]],
                unsigned int vertexIndex [[vertex_id]],
                constant GNDVertexUniforms &uniforms [[buffer(1)]])
{
    GNDVertex in = vertices[vertexIndex];

    GNDVertexOut out;
    out.position = uniforms.projectionMat * float4(in.position, 1.0);
    return out;
}

fragment float4
gndFragmentShader(GNDVertexOut in [[stage_in]],
                  constant GNDFragmentUniforms &uniforms [[buffer(0)]],
                  texture2d<float> texture [[texture(0)]])
{
    return float4(1.0, 1.0, 1.0, 1.0);
}
