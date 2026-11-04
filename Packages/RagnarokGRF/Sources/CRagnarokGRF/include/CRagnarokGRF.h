//
//  CRagnarokGRF.h
//  RagnarokGRF
//
//  Created by Leon Li on 2026/10/29.
//

#ifndef CRagnarokGRF_h
#define CRagnarokGRF_h

#include <stddef.h>
#include <stdint.h>

/// Computes the XXH32 hash with a seed of 0.
uint32_t grf_xxh32(const void *data, size_t length);

/// Computes the XXH3 128-bit hash, written to `hash` as low64 then high64, both little-endian.
void grf_xxh3_128(const void *data, size_t length, uint64_t seed, uint8_t hash[16]);

#endif /* CRagnarokGRF_h */
