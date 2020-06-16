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
    matrix_float4x4 modelViewMat;
    matrix_float4x4 projectionMat;

    vector_float3 lightDirection;
    matrix_float3x3 normalMat;
} RSMVertexUniforms;

typedef struct {
    int fogUse;
    float fogNear;
    float fogFar;
    vector_float3 fogColor;

    vector_float3 lightAmbient;
    vector_float3 lightDiffuse;
    float lightOpacity;
} RSMFragmentUniforms;
