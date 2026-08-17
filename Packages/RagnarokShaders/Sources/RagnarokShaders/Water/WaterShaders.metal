//
//  WaterShaders.metal
//  RagnarokShaders
//
//  Created by Leon Li on 2020/6/28.
//

#include <metal_stdlib>
using namespace metal;

#include "WaterShaderTypes.h"

typedef struct {
    float4 position [[position]];
    float2 textureCoordinate;
    float fogDepth;
} RasterizerData;

vertex RasterizerData
waterVertexShader(const device WaterVertex *vertices [[buffer(0)]],
                  unsigned int vertexIndex [[vertex_id]],
                  constant WaterVertexUniforms &uniforms [[buffer(1)]])
{
    WaterVertex in = vertices[vertexIndex];
    float x = fmod(in.position.x, 2.0);
    float y = fmod(in.position.z, 2.0);
    float diff = x < 1.0 ? y < 1.0 ? 1.0 : -1.0 : 0.0;
    float pi = 3.14159265358979323846264;
    float height = sin((pi / 180.0) * (uniforms.waterOffset + 0.5 * uniforms.wavePitch * (in.position.x + in.position.z + diff))) * uniforms.waveHeight;

    float4 viewPosition = uniforms.viewMatrix * uniforms.modelMatrix * float4(in.position.x, in.position.y + height, in.position.z, 1.0);

    RasterizerData out;
    out.position = uniforms.projectionMatrix * viewPosition;
    out.textureCoordinate = in.textureCoordinate;
    out.fogDepth = -viewPosition.z;
    return out;
}

fragment float4
waterFragmentShader(RasterizerData in [[stage_in]],
                    constant WaterFragmentUniforms &uniforms [[buffer(0)]],
                    texture2d<float> colorTexture [[texture(0)]])
{
    constexpr sampler textureSampler(mag_filter::linear, min_filter::linear);
    float4 color = float4(colorTexture.sample(textureSampler, in.textureCoordinate).rgb, uniforms.opacity);

    if (uniforms.fogUse) {
        float fogAmount = smoothstep(uniforms.fogNear, uniforms.fogFar, in.fogDepth);
        color.rgb = mix(color.rgb, uniforms.fogColor, fogAmount);
    }

    return color;
}
