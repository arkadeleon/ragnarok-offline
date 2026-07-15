//
//  CylinderEffectShaderTypes.h
//  RagnarokShaders
//
//  Created by Leon Li on 2026/6/25.
//

#include <simd/simd.h>

typedef struct {
    vector_float3 position;
    vector_float2 textureCoordinate;
} CylinderEffectVertex;

typedef struct {
    matrix_float4x4 modelMatrix;
    matrix_float4x4 viewMatrix;
    matrix_float4x4 projectionMatrix;
    matrix_float4x4 rotationMatrix;
    vector_float3 worldPosition;
    vector_float3 positionOffset;
    float topRadius;
    float bottomRadius;
    float height;
    float zIndex;
} CylinderEffectVertexUniforms;

typedef struct {
    vector_float4 color;
} CylinderEffectFragmentUniforms;
