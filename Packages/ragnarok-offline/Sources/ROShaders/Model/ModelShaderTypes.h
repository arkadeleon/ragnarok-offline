//
//  ModelShaderTypes.h
//  RagnarokOffline
//
//  Created by Leon Li on 2020/6/9.
//

#include <simd/simd.h>

typedef struct {
    vector_float3 position;
    vector_float3 normal;
    vector_float2 textureCoordinate;
    float alpha;
} ModelVertex;

typedef struct {
    matrix_float4x4 modelMatrix;
    matrix_float4x4 viewMatrix;
    matrix_float4x4 projectionMatrix;

    vector_float3 lightDirection;
    matrix_float3x3 normalMatrix;
} ModelVertexUniforms;

typedef struct {
    int fogUse;
    float fogNear;
    float fogFar;
    vector_float3 fogColor;

    vector_float3 lightAmbient;
    vector_float3 lightDiffuse;
    float lightOpacity;
} ModelFragmentUniforms;
