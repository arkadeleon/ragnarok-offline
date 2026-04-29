//
//  ModelShaders.metal
//  RagnarokShaders
//
//  Created by Leon Li on 2020/6/9.
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
                  constant ModelVertexUniforms &uniforms [[buffer(1)]],
                  const device ModelInstanceUniforms *instances [[buffer(2)]],
                  unsigned int instanceIndex [[instance_id]])
{
    ModelVertex in = vertices[vertexIndex];
    ModelInstanceUniforms instance = instances[instanceIndex];
    float3 worldNormal = normalize(uniforms.normalMatrix * instance.normalMatrix * in.normal);
    float3 lightDirection = normalize(uniforms.lightDirection);
    float dotProduct = dot(worldNormal, lightDirection);

    RasterizerData out;
    out.position = uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.modelMatrix * instance.modelMatrix * float4(in.position, 1.0);
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

    color.rgb *= clamp(lightColor.rgb, 0.0, 1.0);
    color.a *= in.alpha;

    return color;
}
