//
//  hash.c
//  RagnarokGRF
//
//  Created by Leon Li on 2026/10/29.
//

#include "CRagnarokGRF.h"

// Inlining keeps every xxHash symbol private to this file.
#define XXH_INLINE_ALL
#include "xxhash/xxhash.h"

uint32_t grf_xxh32(const void *data, size_t length) {
    return XXH32(data, length, 0);
}

void grf_xxh3_128(const void *data, size_t length, uint64_t seed, uint8_t hash[16]) {
    XXH128_hash_t value = XXH3_128bits_withSeed(data, length, seed);
    for (int i = 0; i < 8; i++) {
        hash[i] = (uint8_t)(value.low64 >> (i * 8));
        hash[i + 8] = (uint8_t)(value.high64 >> (i * 8));
    }
}
