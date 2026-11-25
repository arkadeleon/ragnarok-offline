//
//  EffectPrimitiveShaderTypes.h
//  RagnarokShaders
//
//  Created by Leon Li on 2026/11/24.
//

#include <simd/simd.h>

typedef struct {
    vector_float3 position;
    vector_float2 billboardOffset;
    vector_float2 textureCoordinate;
    vector_float4 color;
} EffectPrimitiveVertex;

typedef struct {
    matrix_float4x4 modelMatrix;
    matrix_float4x4 viewMatrix;
    matrix_float4x4 projectionMatrix;
    float depthBias;
    int renderMode; // 0 = world3D, 1 = billboard3D, 2 = screen2D (world-anchored), 3 = screen2DAbsolute
} EffectPrimitiveVertexUniforms;

typedef struct {
    int fogUse;
    float fogNear;
    float fogFar;
    float alphaTestThreshold;
    vector_float3 fogColor;
} EffectPrimitiveFragmentUniforms;
