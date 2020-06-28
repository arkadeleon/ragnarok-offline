//
//  ModelShaders.metal
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/6/9.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#include "ModelShaderTypes.h"

typedef struct {
    float4 position [[position]];
    float2 textureCoordinate;
    float lightWeighting;
    float alpha;
} ModelRasterizerData;

vertex ModelRasterizerData
modelVertexShader(const device ModelVertex *vertices [[buffer(0)]],
                  unsigned int vertexIndex [[vertex_id]],
                  constant ModelVertexUniforms &uniforms [[buffer(1)]])
{
    ModelVertex in = vertices[vertexIndex];

    ModelRasterizerData out;
    out.position = uniforms.projectionMat * uniforms.modelViewMat * float4(in.position, 1.0);
    out.textureCoordinate = in.textureCoordinate;
    out.alpha = in.alpha;

    float4 lDirection = uniforms.modelViewMat * float4(uniforms.lightDirection, 0.0);
    float3 dirVector = normalize(lDirection.xyz);
    float dotProduct = dot(uniforms.normalMat * in.normal, dirVector);
    out.lightWeighting = max(dotProduct, 0.5);

    return out;
}

fragment float4
modelFragmentShader(ModelRasterizerData in [[stage_in]],
                    constant ModelFragmentUniforms &uniforms [[buffer(0)]],
                    texture2d<float> texture [[texture(0)]])
{
    constexpr sampler textureSampler(address::repeat, mag_filter::linear, min_filter::linear);
    float4 fragColor = texture.sample(textureSampler, in.textureCoordinate);

    if (fragColor.a == 0.0) {
        discard_fragment();
    }

    float3 ambient = uniforms.lightAmbient * uniforms.lightOpacity;
    float3 diffuse = uniforms.lightDiffuse * in.lightWeighting;
    float4 lightColor = float4(ambient + diffuse, 1.0);

    fragColor = fragColor * clamp(lightColor, 0.0, 1.0);
    fragColor.a *= in.alpha;

    if (uniforms.fogUse) {
        float depth = in.position.z / in.position.w;
        float fogFactor = smoothstep(uniforms.fogNear, uniforms.fogFar, depth);
        fragColor = mix(fragColor, float4(uniforms.fogColor, fragColor.w), fogFactor);
    }

    return fragColor;
}
