//
//  ModelShaders.metal
//  RagnarokOffline
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
} RasterizerData;

vertex RasterizerData
modelVertexShader(const device ModelVertex *vertices [[buffer(0)]],
                  unsigned int vertexIndex [[vertex_id]],
                  constant ModelVertexUniforms &uniforms [[buffer(1)]])
{
    ModelVertex in = vertices[vertexIndex];
    float4 lDirection = uniforms.modelviewMatrix * float4(uniforms.lightDirection, 0.0);
    float3 dirVector = normalize(lDirection.xyz);
    float dotProduct = dot(uniforms.normalMatrix * in.normal, dirVector);

    RasterizerData out;
    out.position = uniforms.projectionMatrix * uniforms.modelviewMatrix * float4(in.position, 1.0);
    out.textureCoordinate = in.textureCoordinate;
    out.lightWeighting = max(dotProduct, 0.5);
    out.alpha = in.alpha;
    return out;
}

fragment float4
modelFragmentShader(RasterizerData in [[stage_in]],
                    constant ModelFragmentUniforms &uniforms [[buffer(0)]],
                    texture2d<float> colorTexture [[texture(0)]])
{
    constexpr sampler textureSampler(mag_filter::linear, min_filter::linear);
    float4 color = colorTexture.sample(textureSampler, in.textureCoordinate);

    if (color.a == 0.0) {
        discard_fragment();
    }

    float3 ambient = uniforms.lightAmbient * uniforms.lightOpacity;
    float3 diffuse = uniforms.lightDiffuse * in.lightWeighting;
    float4 lightColor = float4(ambient + diffuse, 1.0);

    color = color * clamp(lightColor, 0.0, 1.0);
    color.a *= in.alpha;

    if (uniforms.fogUse) {
        float depth = in.position.z / in.position.w;
        float fogFactor = smoothstep(uniforms.fogNear, uniforms.fogFar, depth);
        color = mix(color, float4(uniforms.fogColor, color.w), fogFactor);
    }

    return color;
}
