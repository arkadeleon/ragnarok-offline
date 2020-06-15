//
//  RSMShaderTypes.h
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/6/9.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

#include <simd/simd.h>

typedef struct {
    vector_float3 position;
    vector_float3 normal;
    vector_float2 textureCoordinate;
    float alpha;
} RSMVertexIn;

typedef struct {
    matrix_float4x4 model;
    matrix_float3x3 normal;
    matrix_float4x4 view;
    matrix_float4x4 projection;
} RSMVertexUniforms;

typedef struct {
    vector_float3 lightPosition;
} RSMFragmentUniforms;
