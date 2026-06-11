//
//  GroundShaders.metal
//  RagnarokShaders
//
//  Created by Leon Li on 2020/6/23.
//

#include <metal_stdlib>
using namespace metal;

#include "GroundShaderTypes.h"

typedef struct {
    float4 position [[position]];
    float2 textureCoordinate;
    float2 lightmapCoordinate;
    float2 tileColorCoordinate;
    float lightWeighting;
} RasterizerData;

vertex RasterizerData
groundVertexShader(const device GroundVertex *vertices [[buffer(0)]],
                   unsigned int vertexIndex [[vertex_id]],
                   constant GroundVertexUniforms &uniforms [[buffer(1)]])
{
    GroundVertex in = vertices[vertexIndex];
    float3 worldNormal = normalize(uniforms.normalMatrix * in.normal);
    float3 lightDirection = normalize(uniforms.lightDirection);
    float dotProduct = dot(worldNormal, lightDirection);

    RasterizerData out;
    out.position = uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.modelMatrix * float4(in.position, 1.0);
    out.textureCoordinate = in.textureCoordinate;
    out.lightmapCoordinate = in.lightmapCoordinate;
    out.tileColorCoordinate = in.tileColorCoordinate;
    out.lightWeighting = max(dotProduct, 0.1);
    return out;
}

fragment float4
groundFragmentShader(RasterizerData in [[stage_in]],
                     constant GroundFragmentUniforms &uniforms [[buffer(0)]],
                     texture2d<float> colorTexture [[texture(0)]],
                     texture2d<float> lightmap [[texture(1)]],
                     texture2d<float> tileColor [[texture(2)]])
{
    constexpr sampler textureSampler(mag_filter::linear, min_filter::linear);
    float4 texture = colorTexture.sample(textureSampler, in.textureCoordinate);
    float lightWeight = 1.0;

    if (texture.a == 0.0) {
        discard_fragment();
    }

    if (in.tileColorCoordinate.x != 0.0 || in.tileColorCoordinate.y != 0.0) {
        texture *= tileColor.sample(textureSampler, in.tileColorCoordinate);
        lightWeight = in.lightWeighting;
    }

    float3 ambient = uniforms.lightAmbient * uniforms.lightOpacity;
    float3 diffuse = uniforms.lightDiffuse * lightWeight;

    float4 color;

    if (uniforms.lightMapUse) {
        float4 lightmapColor = lightmap.sample(textureSampler, in.lightmapCoordinate);
        float3 lightColor = clamp((ambient + diffuse) * lightmapColor.a, 0.0, 1.0);
        float3 rgb = texture.rgb * lightColor + clamp(lightmapColor.rgb, 0.0, 1.0);
        color = float4(clamp(rgb, 0.0, 1.0), texture.a);
    } else {
        float3 lightColor = clamp(ambient + diffuse, 0.0, 1.0);
        color = float4(texture.rgb * lightColor, texture.a);
    }

    return color;
}
