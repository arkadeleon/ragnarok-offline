//
//  TileShaders.metal
//  RagnarokShaders
//
//  Created by Leon Li on 2026/3/23.
//

#include <metal_stdlib>
using namespace metal;

#include "TileShaderTypes.h"

typedef struct {
    float4 position [[position]];
    float2 textureCoordinate;
} RasterizerData;

// Tile vertices are pre-transformed to world space; apply P × V only — no model matrix.
vertex RasterizerData
tileVertexShader(const device TileVertex *vertices [[buffer(0)]],
                 unsigned int vertexIndex [[vertex_id]],
                 constant TileVertexUniforms &uniforms [[buffer(1)]])
{
    TileVertex in = vertices[vertexIndex];

    float4 clipPos = uniforms.projectionMatrix * uniforms.viewMatrix * float4(in.position, 1.0);

    RasterizerData out;
    out.position = clipPos;
    out.textureCoordinate = in.textureCoordinate;
    return out;
}

fragment float4
tileFragmentShader(RasterizerData in [[stage_in]],
                   texture2d<float> colorTexture [[texture(0)]])
{
    constexpr sampler textureSampler(mag_filter::linear, min_filter::linear);
    float4 color = colorTexture.sample(textureSampler, in.textureCoordinate);
    if (color.a < 0.01) {
        discard_fragment();
    }
    return color;
}
