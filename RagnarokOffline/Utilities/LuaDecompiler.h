//
//  LuaDecompiler.h
//  RagnarokOffline
//
//  Created by Leon Li on 2020/8/5.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LuaDecompiler : NSObject

- (NSData *)decompileData:(NSData *)data;

@end
