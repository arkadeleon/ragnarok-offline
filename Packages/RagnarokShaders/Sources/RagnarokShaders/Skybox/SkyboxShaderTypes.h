//
//  SkyboxShaderTypes.h
//  RagnarokShaders
//
//  Created by Leon Li on 2026/4/8.
//

#include <simd/simd.h>

typedef struct {
    vector_float4 topColor;
    vector_float4 horizonColor;
    vector_float4 bottomColor;
    vector_float4 sphereCenterAndRadius;
    vector_float4 cameraPosition;
    matrix_float4x4 inverseViewProjectionMatrix;
} SkyboxUniforms;
