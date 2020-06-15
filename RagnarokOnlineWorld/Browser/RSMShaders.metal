//
//  RSMShaders.metal
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/6/9.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#include "RSMShaderTypes.h"

typedef struct {
    float4 position [[position]];
    float2 textureCoordinate;
} RSMVertexOut;

vertex RSMVertexOut
rsmVertexShader(const device RSMVertexIn *vertices [[buffer(0)]],
             unsigned int vertexIndex [[vertex_id]],
             constant RSMVertexUniforms &uniforms [[buffer(1)]])
{
    RSMVertexIn in = vertices[vertexIndex];

    RSMVertexOut out;
    out.position = uniforms.projection * uniforms.view * uniforms.model * float4(in.position, 1);
    out.textureCoordinate = in.textureCoordinate;
    return out;
}

fragment float4
rsmFragmentShader(RSMVertexOut in [[stage_in]],
               constant RSMFragmentUniforms &uniforms [[buffer(0)]],
               texture2d<float> texture [[texture(0)]])
{
    constexpr sampler textureSampler(address::repeat, mag_filter::linear, min_filter::linear);
    float4 objectColor = texture.sample(textureSampler, in.textureCoordinate);
    return objectColor;
}
