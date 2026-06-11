//
//  ShadersLibrary.m
//  RagnarokShaders
//
//  Created by Leon Li on 2024/4/10.
//

#import "ShadersLibrary.h"

id<MTLLibrary> RagnarokShadersLibrary(id<MTLDevice> device) {
    static id<MTLLibrary> library = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSBundle *bundle = SWIFTPM_MODULE_BUNDLE;
        library = [device newDefaultLibraryWithBundle:bundle error:nil];
    });
    return library;
}
