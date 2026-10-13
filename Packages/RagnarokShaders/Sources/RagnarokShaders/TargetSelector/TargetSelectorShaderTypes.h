//
//  TargetSelectorShaderTypes.h
//  RagnarokShaders
//
//  Created by Leon Li on 2026/10/13.
//

#include <simd/simd.h>

typedef struct {
    vector_float2 position;             // in pixels, 32 = 1 world unit, x right and y up on screen
    vector_float4 color;
} TargetSelectorVertex;

typedef struct {
    matrix_float4x4 modelMatrix;
    matrix_float4x4 viewMatrix;
    matrix_float4x4 projectionMatrix;
    vector_float3 worldPosition;        // (map x, map y, altitude) of the target's anchor
    vector_float2 offset;               // in pixels, added to every vertex
} TargetSelectorVertexUniforms;
