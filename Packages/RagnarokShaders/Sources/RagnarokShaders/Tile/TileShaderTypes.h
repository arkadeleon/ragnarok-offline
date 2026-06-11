//
//  TileShaderTypes.h
//  RagnarokShaders
//
//  Created by Leon Li on 2026/3/23.
//

#include <simd/simd.h>

typedef struct {
    vector_float3 position;
    vector_float2 textureCoordinate;
} TileVertex;

typedef struct {
    matrix_float4x4 viewMatrix;
    matrix_float4x4 projectionMatrix;
} TileVertexUniforms;
