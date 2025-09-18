//
//  WaterShaderTypes.h
//  MetalShaders
//
//  Created by Leon Li on 2020/6/28.
//

#include <simd/simd.h>

typedef struct {
    vector_float3 position;
    vector_float2 textureCoordinate;
} WaterVertex;

typedef struct {
    matrix_float4x4 modelMatrix;
    matrix_float4x4 viewMatrix;
    matrix_float4x4 projectionMatrix;

    float waveHeight;
    float wavePitch;
    float waterOffset;
} WaterVertexUniforms;

typedef struct {
    int fogUse;
    float fogNear;
    float fogFar;
    vector_float3 fogColor;

    vector_float3 lightAmbient;
    vector_float3 lightDiffuse;
    float lightOpacity;

    float opacity;
} WaterFragmentUniforms;
