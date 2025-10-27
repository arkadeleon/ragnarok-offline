//
//  ShadersLibrary.m
//  RagnarokShaders
//
//  Created by Leon Li on 2024/4/10.
//

#import "ShadersLibrary.h"

id<MTLLibrary> RagnarokCreateShadersLibrary(id<MTLDevice> device) {
    NSBundle *bundle = SWIFTPM_MODULE_BUNDLE;
    return [device newDefaultLibraryWithBundle:bundle error:nil];
}
