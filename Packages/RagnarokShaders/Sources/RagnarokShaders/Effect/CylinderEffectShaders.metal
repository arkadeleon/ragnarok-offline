//
//  CylinderEffectShaders.metal
//  RagnarokShaders
//
//  Created by Leon Li on 2026/6/25.
//

#include <metal_stdlib>
using namespace metal;

#include "CylinderEffectShaderTypes.h"

typedef struct {
    float4 position [[position]];
    float2 textureCoordinate;
} CylinderEffectRasterizerData;

vertex CylinderEffectRasterizerData
cylinderEffectVertexShader(const device CylinderEffectVertex *vertices [[buffer(0)]],
                           unsigned int vertexIndex [[vertex_id]],
                           constant CylinderEffectVertexUniforms &uniforms [[buffer(1)]])
{
    CylinderEffectVertex in = vertices[vertexIndex];

    bool isTop = in.position.z > 0.5;
    float radius = isTop ? uniforms.topRadius : uniforms.bottomRadius;
    float height = isTop ? uniforms.height : 0.0;

    float3 localPosition = float3(
        in.position.x * radius,
        height,
        in.position.y * radius
    );
    localPosition = (uniforms.rotationMatrix * float4(localPosition, 0.0)).xyz;

    float3 worldPosition = uniforms.worldPosition + uniforms.positionOffset + localPosition;
    float4 clipPosition = uniforms.projectionMatrix * uniforms.viewMatrix * float4(worldPosition, 1.0);
    clipPosition.z -= uniforms.zIndex * 0.001 * clipPosition.w;

    CylinderEffectRasterizerData out;
    out.position = clipPosition;
    out.textureCoordinate = in.textureCoordinate;
    return out;
}

fragment float4
cylinderEffectFragmentShader(CylinderEffectRasterizerData in [[stage_in]],
                             constant CylinderEffectFragmentUniforms &uniforms [[buffer(0)]],
                             texture2d<float> colorTexture [[texture(0)]])
{
    if (uniforms.color.a <= 0.0) {
        discard_fragment();
    }

    constexpr sampler textureSampler(
        mag_filter::linear,
        min_filter::linear,
        s_address::repeat,
        t_address::clamp_to_edge
    );
    float4 color = colorTexture.sample(textureSampler, in.textureCoordinate);
    if (color.a < 0.01) {
        discard_fragment();
    }
    if (color.r < 0.01 && color.g < 0.01 && color.b < 0.01) {
        discard_fragment();
    }

    return color * uniforms.color;
}
