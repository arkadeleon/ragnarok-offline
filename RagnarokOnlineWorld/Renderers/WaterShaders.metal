//
//  WaterShaders.metal
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/6/28.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#include "WaterShaderTypes.h"

typedef struct {
    float4 position [[position]];
} WaterRasterizerData;

vertex WaterRasterizerData
waterVertexShader(const device WaterVertex *vertices [[buffer(0)]],
                  unsigned int vertexIndex [[vertex_id]],
                  constant WaterVertexUniforms &uniforms [[buffer(1)]])
{
    WaterVertex in = vertices[vertexIndex];

    WaterRasterizerData out;
    return out;
}

fragment float4
waterFragmentShader(WaterRasterizerData in [[stage_in]],
                    constant WaterFragmentUniforms &uniforms [[buffer(0)]],
                    texture2d<float> texture [[texture(0)]])
{
    return float4(1.0, 1.0, 1.0, 1.0);
}
