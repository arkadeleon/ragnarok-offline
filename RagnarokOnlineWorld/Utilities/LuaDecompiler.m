//
//  LuaDecompiler.m
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/8/5.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

#import "LuaDecompiler.h"
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
#include "lobject.h"

char *ProcessCode(const Proto *f, int indent);

@interface LuaDecompiler () {
    lua_State *l;
}

@end

@implementation LuaDecompiler

- (instancetype)init {
    self = [super init];
    if (self) {
        l = luaL_newstate();
        luaL_openlibs(l);
    }
    return self;
}

- (void)dealloc {
    lua_close(l);
}

- (NSData *)decompileData:(NSData *)data {
    luaL_loadbuffer(l, data.bytes, data.length, nil);

    Closure *c = (Closure *)lua_topointer(l, -1);
    Proto *f = c->l.p;
    char *code = ProcessCode(f, 4);

    NSData *output = [NSData dataWithBytesNoCopy:code length:strlen(code)];
    return output;
}

@end
