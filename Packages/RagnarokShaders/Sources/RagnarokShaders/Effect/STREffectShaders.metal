//
//  STREffectShaders.metal
//  RagnarokShaders
//
//  Created by Leon Li on 2023/11/24.
//

#include <metal_stdlib>
using namespace metal;

#include "STREffectShaderTypes.h"

typedef struct {
    float4 position [[position]];
    float2 textureCoordinate;
    float fogDepth;
} RasterizerData;

float4x4 project(float4x4 matrix, float3 position) {
    // Matrix translation
    matrix[3].x += matrix[0].x * position.x + matrix[1].x * position.y + matrix[2].x * position.z;
    matrix[3].y += matrix[0].y * position.x + matrix[1].y * position.y + matrix[2].y * position.z;
    matrix[3].z += matrix[0].z * position.x + matrix[1].z * position.y + matrix[2].z * position.z;
    matrix[3].w += matrix[0].w * position.x + matrix[1].w * position.y + matrix[2].w * position.z;

    // Spherical billboard
    matrix[0].xyz = float3(1.0, 0.0, 0.0);
    matrix[1].xyz = float3(0.0, 1.0, 0.0);
    matrix[2].xyz = float3(0.0, 0.0, 1.0);

    return matrix;
}

vertex RasterizerData
strEffectVertexShader(const device STREffectVertex *vertices [[buffer(0)]],
                      unsigned int vertexIndex [[vertex_id]],
                      constant STREffectVertexUniforms &uniforms [[buffer(1)]])
{
    const float pixelRatio = 1.0 / 35.0;

    STREffectVertex in = vertices[vertexIndex];
    RasterizerData out;
    out.textureCoordinate = in.textureCoordinate;

    if (uniforms.renderMode == 1) {
        // Ground mode: vertices are already placed in world space with terrain heights.
        float4 viewPosition = uniforms.viewMatrix * uniforms.modelMatrix * float4(in.position, 1.0);
        float4 position = uniforms.projectionMatrix * viewPosition;
        position.z -= uniforms.depthBias;
        out.position = position;
        out.fogDepth = -viewPosition.z;
        return out;
    }

    if (uniforms.renderMode == 2) {
        // Screen mode: anchor to projected world position in NDC and apply 2D/3D screen transform.
        float4 clipAnchor = uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.modelMatrix * float4(uniforms.spritePosition, 1.0);
        float2 ndcAnchor = abs(clipAnchor.w) > 0.0001 ? (clipAnchor.xy / clipAnchor.w) : float2(0.0, 0.0);

        float4 local = uniforms.spriteAngle * float4(in.position.x, -in.position.y, 0.0, 1.0);
        float2 offsetPixels = float2(local.x + uniforms.spriteOffset.x, local.y - uniforms.spriteOffset.y);
        float2 ndcPosition = ndcAnchor + offsetPixels * uniforms.screenScale;

        out.position = float4(ndcPosition, 0.0, 1.0);
        out.fogDepth = 0.0;
        return out;
    }

    // Billboard mode (default): spherical billboard facing the camera.
    float4 position = uniforms.spriteAngle * float4(in.position.x * pixelRatio, -in.position.y * pixelRatio, 0.0, 1.0);
    position.x += uniforms.spriteOffset.x * pixelRatio;
    position.y -= uniforms.spriteOffset.y * pixelRatio + 0.5;

    float4 viewPosition = project(uniforms.viewMatrix * uniforms.modelMatrix, uniforms.spritePosition) * position;
    position = uniforms.projectionMatrix * viewPosition;
    position.z -= uniforms.depthBias;

    out.position = position;
    out.fogDepth = -viewPosition.z;
    return out;
}

fragment float4
strEffectFragmentShader(RasterizerData in [[stage_in]],
                        constant STREffectFragmentUniforms &uniforms [[buffer(0)]],
                        texture2d<float> colorTexture [[texture(0)]])
{
    constexpr sampler textureSampler(mag_filter::linear, min_filter::linear);
    float4 color = colorTexture.sample(textureSampler, in.textureCoordinate);
    if (color.r < 0.1 && color.g < 0.1 && color.b < 0.1) {
        discard_fragment();
    }

    color = color * uniforms.spriteColor;

    if (uniforms.fogUse) {
        float fogAmount = smoothstep(uniforms.fogNear, uniforms.fogFar, in.fogDepth);
        color.rgb = mix(color.rgb, uniforms.fogColor, fogAmount);
    }

    return color;
}
