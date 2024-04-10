//
//  ShadersLibrary.m
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/10.
//

#import "ShadersLibrary.h"

NS_ASSUME_NONNULL_BEGIN

@interface RagnarokOfflineShaders_SWIFTPM_MODULE_BUNDLER_FINDER : NSObject
@end

@implementation RagnarokOfflineShaders_SWIFTPM_MODULE_BUNDLER_FINDER
@end

NSBundle *RagnarokOfflineShaders_SWIFTPM_MODULE_BUNDLE() {
    NSString *bundleName = @"ragnarok-offline_RagnarokOfflineShaders";

    NSArray<NSURL *> *candidates = @[
        NSBundle.mainBundle.resourceURL,
        [NSBundle bundleForClass:[RagnarokOfflineShaders_SWIFTPM_MODULE_BUNDLER_FINDER class]].resourceURL,
        NSBundle.mainBundle.bundleURL
    ];

    for (NSURL *candiate in candidates) {
        NSURL *bundlePath = [candiate URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.bundle", bundleName]];

        NSBundle *bundle = [NSBundle bundleWithURL:bundlePath];
        if (bundle != nil) {
            return bundle;
        }
    }

    @throw [[NSException alloc] initWithName:@"SwiftPMResourcesAccessor" reason:[NSString stringWithFormat:@"unable to find bundle named %@", bundleName] userInfo:nil];
}

NS_ASSUME_NONNULL_END

id<MTLLibrary> RagnarokOfflineCreateShadersLibrary(id<MTLDevice> device) {
    NSBundle *bundle = RagnarokOfflineShaders_SWIFTPM_MODULE_BUNDLE();
    return [device newDefaultLibraryWithBundle:bundle error:nil];
}
