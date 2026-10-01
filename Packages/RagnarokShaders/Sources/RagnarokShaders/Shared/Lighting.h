//
//  Lighting.h
//  RagnarokShaders
//
//  Created by Leon Li on 2026/10/1.
//

#ifdef __METAL_VERSION__

#include <metal_stdlib>

/// The brightest light color the map can reach. Unshaded models are lit with this color.
inline metal::float3 lightMaxColor(metal::float3 lightAmbient, metal::float3 lightDiffuse) {
    metal::float3 maxLight = metal::max(lightDiffuse, lightAmbient);
    metal::float3 minLight = metal::min(lightDiffuse, lightAmbient);
    return metal::min(maxLight + (1.0 - maxLight) * minLight, 1.0);
}

/// The light color of a surface whose normal is lit by `dotProduct`.
inline metal::float3 lightColor(float dotProduct, metal::float3 lightAmbient, metal::float3 lightDiffuse) {
    float NL = metal::clamp(dotProduct, 0.0, 1.0);
    metal::float3 ambientFactor = (1.0 - lightAmbient) * lightAmbient;
    metal::float3 ambient = lightAmbient - ambientFactor + ambientFactor * lightDiffuse;
    metal::float3 diffuseFactor = (1.0 - lightDiffuse) * lightDiffuse;
    metal::float3 diffuse = lightDiffuse - diffuseFactor + diffuseFactor * lightAmbient;
    metal::float3 lightColor = metal::min(NL * diffuse + ambient, 1.0);
    return metal::clamp(metal::min(lightColor, lightMaxColor(lightAmbient, lightDiffuse)), 0.0, 1.0);
}

#endif
