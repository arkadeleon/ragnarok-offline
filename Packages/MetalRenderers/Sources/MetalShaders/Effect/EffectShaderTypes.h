//
//  EffectShaderTypes.h
//  MetalShaders
//
//  Created by Leon Li on 2023/11/24.
//

#include <simd/simd.h>

typedef struct {
    vector_float2 position;
    vector_float2 textureCoordinate;
} EffectVertex;

typedef struct {
    matrix_float4x4 modelMatrix;
    matrix_float4x4 viewMatrix;
    matrix_float4x4 projectionMatrix;

    matrix_float4x4 spriteAngle;
    vector_float3 spritePosition;
    vector_float2 spriteOffset;
} EffectVertexUniforms;

typedef struct {
    vector_float4 spriteColor;

    int fogUse;
    float fogNear;
    float fogFar;
    vector_float3 fogColor;
} EffectFragmentUniforms;
