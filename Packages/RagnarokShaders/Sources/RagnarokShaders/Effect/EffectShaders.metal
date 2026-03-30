//
//  EffectShaders.metal
//  RagnarokShaders
//
//  Created by Leon Li on 2023/11/24.
//

#include <metal_stdlib>
using namespace metal;

#include "EffectShaderTypes.h"

typedef struct {
    float4 position [[position]];
    float2 textureCoordinate;
} RasterizerData;

float4x4 project(float4x4 matrix, float3 position) {
    // xyz = x(-z)y + middle of cell (0.5)
    float x = position.x + 0.5;
    float y = -position.z;
    float z = position.y + 0.5;

    // Matrix translation
    matrix[3].x += matrix[0].x * x + matrix[1].x * y + matrix[2].x * z;
    matrix[3].y += matrix[0].y * x + matrix[1].y * y + matrix[2].y * z;
    matrix[3].z += matrix[0].z * x + matrix[1].z * y + matrix[2].z * z;
    matrix[3].w += matrix[0].w * x + matrix[1].w * y + matrix[2].w * z;

    // Spherical billboard
    matrix[0].xyz = float3(1.0, 0.0, 0.0);
    matrix[1].xyz = float3(0.0, 1.0, 0.0);
    matrix[2].xyz = float3(0.0, 0.0, 1.0);

    return matrix;
}

vertex RasterizerData
effectVertexShader(const device EffectVertex *vertices [[buffer(0)]],
                   unsigned int vertexIndex [[vertex_id]],
                   constant EffectVertexUniforms &uniforms [[buffer(1)]])
{
    const float pixelRatio = 1.0 / 35.0;

    EffectVertex in = vertices[vertexIndex];

    float4 position = uniforms.spriteAngle * float4(in.position.x * pixelRatio, -in.position.y * pixelRatio, 0.0, 1.0);
    position.x += uniforms.spriteOffset.x * pixelRatio;
    position.y -= uniforms.spriteOffset.y * pixelRatio + 0.5;

    position = uniforms.projectionMatrix * project(uniforms.viewMatrix * uniforms.modelMatrix, uniforms.spritePosition) * position;
    position.z -= 0.1;

    RasterizerData out;
    out.position = position;
    out.textureCoordinate = in.textureCoordinate;
    return out;
}

fragment float4
effectFragmentShader(RasterizerData in [[stage_in]],
                     constant EffectFragmentUniforms &uniforms [[buffer(0)]],
                     texture2d<float> colorTexture [[texture(0)]])
{
    constexpr sampler textureSampler(mag_filter::linear, min_filter::linear);
    float4 color = colorTexture.sample(textureSampler, in.textureCoordinate);
    if (color.r < 0.1 && color.g < 0.1 && color.b < 0.1) {
        discard_fragment();
    }

    color = color * uniforms.spriteColor;

    if (uniforms.fogUse) {
        float depth = in.position.z / in.position.w;
        float fogFactor = smoothstep(uniforms.fogNear, uniforms.fogFar, depth);
        color = mix(color, float4(uniforms.fogColor, color.w), fogFactor);
    }

    return color;
}
