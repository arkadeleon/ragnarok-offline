//
//  GroundShaders.metal
//  RagnarokShaders
//
//  Created by Leon Li on 2020/6/23.
//

#include <metal_stdlib>
using namespace metal;

#include "GroundShaderTypes.h"
#include "../Shared/Lighting.h"

typedef struct {
    float4 position [[position]];
    float2 textureCoordinate;
    float2 lightmapCoordinate;
    float2 tileColorCoordinate;
    float3 lightColor;
    float fogDepth;
} RasterizerData;

vertex RasterizerData
groundVertexShader(const device GroundVertex *vertices [[buffer(0)]],
                   unsigned int vertexIndex [[vertex_id]],
                   constant GroundVertexUniforms &uniforms [[buffer(1)]])
{
    GroundVertex in = vertices[vertexIndex];
    float3x3 modelRotation = float3x3(uniforms.modelMatrix[0].xyz,
                                      uniforms.modelMatrix[1].xyz,
                                      uniforms.modelMatrix[2].xyz);
    float3 worldNormal = normalize(modelRotation * in.normal);
    float3 lightDirection = normalize(uniforms.lightDirection);
    float dotProduct = dot(worldNormal, lightDirection);

    float4 viewPosition = uniforms.viewMatrix * uniforms.modelMatrix * float4(in.position, 1.0);

    RasterizerData out;
    out.position = uniforms.projectionMatrix * viewPosition;
    out.textureCoordinate = in.textureCoordinate;
    out.lightmapCoordinate = in.lightmapCoordinate;
    out.tileColorCoordinate = in.tileColorCoordinate;
    out.lightColor = lightColor(dotProduct, uniforms.lightAmbient, uniforms.lightDiffuse);
    out.fogDepth = -viewPosition.z;
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

    if (texture.a == 0.0) {
        discard_fragment();
    }

    if (in.tileColorCoordinate.x != 0.0 || in.tileColorCoordinate.y != 0.0) {
        texture.rgb *= tileColor.sample(textureSampler, in.tileColorCoordinate).rgb;
    }

    float3 rgb = texture.rgb * in.lightColor;

    if (uniforms.lightMapUse) {
        float4 lightmapColor = lightmap.sample(textureSampler, in.lightmapCoordinate);
        rgb = rgb * lightmapColor.a + clamp(lightmapColor.rgb, 0.0, 1.0);
    }

    float4 color = float4(clamp(rgb, 0.0, 1.0), texture.a);

    if (uniforms.fogUse) {
        float fogAmount = smoothstep(uniforms.fogNear, uniforms.fogFar, in.fogDepth);
        color.rgb = mix(color.rgb, uniforms.fogColor, fogAmount);
    }

    return color;
}
