//
//  ShaderTypes.h
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/5/23.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

#include <simd/simd.h>

typedef struct {
    vector_float2 position;
    vector_float2 textureCoordinate;
} VertexIn;

typedef struct {
    matrix_float4x4 transform;
} VertexUniforms;
