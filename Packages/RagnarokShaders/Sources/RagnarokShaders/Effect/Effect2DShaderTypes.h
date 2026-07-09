//
//  Effect2DShaderTypes.h
//  RagnarokShaders
//
//  Created by Leon Li on 2026/7/9.
//

#include <simd/simd.h>

typedef struct {
    vector_float2 position;
    vector_float2 textureCoordinate;
} Effect2DVertex;

typedef struct {
    matrix_float4x4 viewMatrix;
    matrix_float4x4 projectionMatrix;
    matrix_float4x4 rotationMatrix;
    vector_float3 worldPosition;
    vector_float2 size;
    vector_float2 offset;
    float zIndex;
} Effect2DVertexUniforms;

typedef struct {
    vector_float4 color;
} Effect2DFragmentUniforms;
