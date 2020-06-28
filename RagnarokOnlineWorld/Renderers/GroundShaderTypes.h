//
//  GroundShaderTypes.h
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/6/22.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

#include <simd/simd.h>

typedef struct {
    vector_float3 position;
    vector_float3 normal;
    vector_float2 textureCoordinate;
    vector_float2 lightmapCoordinate;
    vector_float2 tileColorCoordinate;
} GroundVertex;

typedef struct {
    matrix_float4x4 projectionMat;
} GroundVertexUniforms;

typedef struct {
} GroundFragmentUniforms;
