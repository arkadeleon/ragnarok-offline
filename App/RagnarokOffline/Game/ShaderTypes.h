//
//  ShaderTypes.h
//  RagnarokOffline
//
//  Created by Leon Li on 2020/5/23.
//

#include <simd/simd.h>

typedef struct {
    vector_float3 position;
    vector_float2 textureCoordinate;
    vector_float3 normal;
} VertexIn;

typedef struct {
    matrix_float4x4 model;
    matrix_float3x3 normal;
    matrix_float4x4 view;
    matrix_float4x4 projection;
} VertexUniforms;

typedef struct {
    vector_float3 lightPosition;
} FragmentUniforms;
