//
//  EffectPrimitiveShaders.metal
//  RagnarokShaders
//
//  Created by Leon Li on 2026/11/24.
//

#include <metal_stdlib>
using namespace metal;

#include "EffectPrimitiveShaderTypes.h"

typedef struct {
    float4 position [[position]];
    float2 textureCoordinate;
    float4 color;
    float fogDepth;
} EffectPrimitiveRasterizerData;

vertex EffectPrimitiveRasterizerData
effectPrimitiveVertexShader(const device EffectPrimitiveVertex *vertices [[buffer(0)]],
                            unsigned int vertexIndex [[vertex_id]],
                            constant EffectPrimitiveVertexUniforms &uniforms [[buffer(1)]])
{
    EffectPrimitiveVertex in = vertices[vertexIndex];
    EffectPrimitiveRasterizerData out;

    if (uniforms.renderMode == 3) {
        // Screen2DAbsolute: classic 640x480 top-left pixel coordinates mapped directly to Metal NDC.
        float2 pixel = in.position.xy + in.billboardOffset;
        float2 ndc = float2(pixel.x / 320.0 - 1.0, 1.0 - pixel.y / 240.0);
        out.position = float4(ndc, 0.5, 1.0);
        out.textureCoordinate = in.textureCoordinate;
        out.color = in.color;
        out.fogDepth = 0.0;
        return out;
    }

    float4 viewPosition;
    if (uniforms.renderMode == 1) {
        // Billboard3D: expand billboardOffset along camera-aligned world right/up axes.
        float3 cameraRight = float3(uniforms.viewMatrix[0][0], uniforms.viewMatrix[1][0], uniforms.viewMatrix[2][0]);
        float3 cameraUp = float3(uniforms.viewMatrix[0][1], uniforms.viewMatrix[1][1], uniforms.viewMatrix[2][1]);
        float3 anchor = (uniforms.modelMatrix * float4(in.position, 1.0)).xyz;
        float3 worldPosition = anchor + cameraRight * in.billboardOffset.x + cameraUp * in.billboardOffset.y;
        viewPosition = uniforms.viewMatrix * float4(worldPosition, 1.0);
    } else {
        // World3D (0) & Screen2D anchor (2): transform position into view space.
        viewPosition = uniforms.viewMatrix * uniforms.modelMatrix * float4(in.position, 1.0);
    }

    // Apply depthBias in view space so it remains compatible with Reversed-Z projections.
    viewPosition.z += uniforms.depthBias;

    float4 clipPosition = uniforms.projectionMatrix * viewPosition;
    if (uniforms.renderMode == 2) {
        // Screen2D: offset projected 3D anchor by 480p-referenced pixels scaled uniformly by viewport height
        // so circles stay circular at any aspect ratio and DPI.
        float aspect = (uniforms.viewportSize.x > 0.0 && uniforms.viewportSize.y > 0.0)
            ? (uniforms.viewportSize.x / uniforms.viewportSize.y)
            : (640.0 / 480.0);
        float halfHeight = 240.0;
        float halfWidth = halfHeight * aspect;
        clipPosition.x += (in.billboardOffset.x / halfWidth) * clipPosition.w;
        clipPosition.y -= (in.billboardOffset.y / halfHeight) * clipPosition.w;
    }

    out.position = clipPosition;
    out.textureCoordinate = in.textureCoordinate;
    out.color = in.color;
    out.fogDepth = uniforms.renderMode == 2 ? 0.0 : -viewPosition.z;
    return out;
}

fragment float4
effectPrimitiveFragmentShader(EffectPrimitiveRasterizerData in [[stage_in]],
                              constant EffectPrimitiveFragmentUniforms &uniforms [[buffer(0)]],
                              texture2d<float> colorTexture [[texture(0)]])
{
    constexpr sampler textureSampler(mag_filter::linear, min_filter::linear, address::repeat);
    float4 color = colorTexture.sample(textureSampler, in.textureCoordinate) * in.color;
    if (color.a <= uniforms.alphaTestThreshold) {
        discard_fragment();
    }

    if (uniforms.fogUse != 0) {
        float fogAmount = smoothstep(uniforms.fogNear, uniforms.fogFar, in.fogDepth);
        color.rgb = mix(color.rgb, uniforms.fogColor, fogAmount);
    }

    return color;
}
