//
//  ShadersLibrary.m
//  MetalShaders
//
//  Created by Leon Li on 2024/4/10.
//

#import "ShadersLibrary.h"

id<MTLLibrary> ROCreateShadersLibrary(id<MTLDevice> device) {
    NSBundle *bundle = SWIFTPM_MODULE_BUNDLE;
    return [device newDefaultLibraryWithBundle:bundle error:nil];
}
