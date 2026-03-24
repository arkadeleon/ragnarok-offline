//
//  SpriteShaderTypes.h
//  RagnarokShaders
//
//  Created by Leon Li on 2026/3/23.
//

#include <simd/simd.h>

typedef struct {
    vector_float2 position;
    vector_float2 textureCoordinate;
} SpriteVertex;

typedef struct {
    matrix_float4x4 viewMatrix;
    matrix_float4x4 projectionMatrix;
    vector_float4 spriteWorldPosition;  // xyz = world-space anchor, w = unused
} SpriteVertexUniforms;
