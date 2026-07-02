//
//  SPREffectShaderTypes.h
//  RagnarokShaders
//
//  Created by Leon Li on 2026/7/2.
//

#include <simd/simd.h>

typedef struct {
    vector_float2 position;
    vector_float2 textureCoordinate;
} SPREffectVertex;

typedef struct {
    matrix_float4x4 viewMatrix;
    matrix_float4x4 projectionMatrix;
    vector_float3 worldPosition;
    vector_float2 size;
    float zIndex;
} SPREffectVertexUniforms;

