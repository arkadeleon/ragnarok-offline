//
//  EffectViewerTargetShaders.metal
//  RagnarokOffline
//
//  Created by Leon Li on 2026/11/26.
//

#include <metal_stdlib>
using namespace metal;

struct EffectViewerTargetVertex {
    float2 position;
    float2 textureCoordinate;
    float4 color;
};

struct EffectViewerTargetUniforms {
    float4x4 modelMatrix;
    float4x4 viewMatrix;
    float4x4 projectionMatrix;
    float4 spriteWorldPosition;
    float4 cameraPosition;
    float4 viewport;
};

struct EffectViewerTargetRasterizerData {
    float4 position [[position]];
    float2 textureCoordinate;
    float4 color;
};

struct EffectViewerTargetFragmentOut {
    float4 color [[color(0)]];
    float depth [[depth(any)]];
};

vertex EffectViewerTargetRasterizerData
effectViewerTargetVertex(const device EffectViewerTargetVertex *vertices [[buffer(0)]],
                         unsigned int vertexIndex [[vertex_id]],
                         constant EffectViewerTargetUniforms &uniforms [[buffer(1)]])
{
    EffectViewerTargetVertex in = vertices[vertexIndex];

    float3 cameraRight = float3(uniforms.viewMatrix[0][0], uniforms.viewMatrix[1][0], uniforms.viewMatrix[2][0]);
    float3 cameraUp    = float3(uniforms.viewMatrix[0][1], uniforms.viewMatrix[1][1], uniforms.viewMatrix[2][1]);

    float3 basePos = (uniforms.modelMatrix * float4(uniforms.spriteWorldPosition.xyz, 1.0)).xyz;
    const float pixelRatio = 1.0 / 32.0;
    float3 worldPos = basePos + cameraRight * in.position.x * pixelRatio + cameraUp * in.position.y * pixelRatio;

    float4 viewPos = uniforms.viewMatrix * float4(worldPos, 1.0);

    EffectViewerTargetRasterizerData out;
    out.position = uniforms.projectionMatrix * viewPos;
    out.textureCoordinate = in.textureCoordinate;
    out.color = in.color;
    return out;
}

fragment EffectViewerTargetFragmentOut
effectViewerTargetFragment(EffectViewerTargetRasterizerData in [[stage_in]],
                           constant EffectViewerTargetUniforms &uniforms [[buffer(0)]],
                           texture2d<float> colorTexture [[texture(0)]])
{
    constexpr sampler textureSampler(mag_filter::linear, min_filter::linear);
    float4 color = colorTexture.sample(textureSampler, in.textureCoordinate);
    if (color.a < 0.01) {
        discard_fragment();
    }

    EffectViewerTargetFragmentOut out;
    out.color = float4(color.rgb * in.color.rgb * in.color.a, color.a * in.color.a);
    out.depth = in.position.z;

    if (uniforms.cameraPosition.w != 0.0) {
        float2 viewportPoint = in.position.xy - uniforms.viewport.xy;
        float2 ndc = float2(viewportPoint.x / uniforms.viewport.z * 2.0 - 1.0,
                            1.0 - viewportPoint.y / uniforms.viewport.w * 2.0);

        float3 rayView = float3((ndc.x + uniforms.projectionMatrix[2][0]) / uniforms.projectionMatrix[0][0],
                                (ndc.y + uniforms.projectionMatrix[2][1]) / uniforms.projectionMatrix[1][1],
                                -1.0);

        float3 cameraRight   = float3(uniforms.viewMatrix[0][0], uniforms.viewMatrix[1][0], uniforms.viewMatrix[2][0]);
        float3 cameraUp      = float3(uniforms.viewMatrix[0][1], uniforms.viewMatrix[1][1], uniforms.viewMatrix[2][1]);
        float3 cameraBack    = float3(uniforms.viewMatrix[0][2], uniforms.viewMatrix[1][2], uniforms.viewMatrix[2][2]);
        float3 cameraForward = -cameraBack;
        float3 rayWorld = cameraRight * rayView.x + cameraUp * rayView.y + cameraBack * rayView.z;

        float3 anchor = (uniforms.modelMatrix * float4(uniforms.spriteWorldPosition.xyz, 1.0)).xyz;
        float3 cameraPos = uniforms.cameraPosition.xyz;

        float3 worldUp = normalize((uniforms.modelMatrix * float4(0.0, 1.0, 0.0, 0.0)).xyz);
        float3 planeNormal = cameraForward - worldUp * dot(cameraForward, worldUp);
        if (length(planeNormal) < 0.000001) {
            planeNormal = cameraForward;
        }
        planeNormal = normalize(planeNormal);

        float3 planePoint = anchor - planeNormal * 0.5;
        float denom = dot(planeNormal, rayWorld);
        if (abs(denom) > 0.000001) {
            float t = dot(planePoint - cameraPos, planeNormal) / denom;
            float4 hitClip = uniforms.projectionMatrix * uniforms.viewMatrix * float4(cameraPos + rayWorld * t, 1.0);
            out.depth = hitClip.z / max(hitClip.w, 0.000001);
        }
    }

    return out;
}
