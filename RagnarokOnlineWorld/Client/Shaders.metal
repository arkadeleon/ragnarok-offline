//
//  Shaders.metal
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/5/23.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

#include "ShaderTypes.h"

#include <metal_stdlib>
using namespace metal;

typedef struct {
    vector_float4 position [[position]];
    vector_float4 color;
} VertexOut;

vertex VertexOut vertexShader(const device VertexIn *vertices [[buffer(0)]], unsigned int vertexIndex [[vertex_id]]) {
    VertexIn in = vertices[vertexIndex];

    VertexOut out;
    out.position = float4(in.position, 0, 1);
    out.color = in.color;
    return out;
}

fragment float4 fragmentShader(VertexOut in [[stage_in]]) {
    return in.color;
}
