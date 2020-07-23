//
//  Shaders.metal
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/5/23.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#include "ShaderTypes.h"

typedef struct {
    float4 position [[position]];
    float3 fragmentPosition;
    float2 textureCoordinate;
    float3 normal;
} VertexOut;

vertex VertexOut
vertexShader(const device VertexIn *vertices [[buffer(0)]],
             unsigned int vertexIndex [[vertex_id]],
             constant VertexUniforms &uniforms [[buffer(1)]])
{
    VertexIn in = vertices[vertexIndex];

    VertexOut out;
    out.position = uniforms.projection * uniforms.view * uniforms.model * float4(in.position, 1);
    out.fragmentPosition = float3(uniforms.model * float4(in.position, 1));
    out.textureCoordinate = in.textureCoordinate;
    out.normal = uniforms.normal * in.normal;
    return out;
}

fragment float4
fragmentShader(VertexOut in [[stage_in]],
               constant FragmentUniforms &uniforms [[buffer(0)]],
               texture2d<float> texture [[texture(0)]])
{
    float3 lightColor(1.0, 1.0, 1.0);

    float ambientStrength = 0.2;
    float3 ambient = ambientStrength * lightColor;

    float3 normal = normalize(in.normal);
    float3 lightDirection = normalize(uniforms.lightPosition - in.fragmentPosition);
    float diff = max(dot(normal, lightDirection), 0.0);
    float3 diffuse = diff * lightColor;

    constexpr sampler textureSampler(address::repeat, mag_filter::linear, min_filter::linear);
    float4 objectColor = texture.sample(textureSampler, in.textureCoordinate);

    float3 result = (ambient + diffuse) * objectColor.rgb;
    return float4(result, 1.0);
}
