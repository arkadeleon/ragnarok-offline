//
//  LuaDecompiler.m
//  RagnarokOffline
//
//  Created by Leon Li on 2020/8/5.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

#import "LuaDecompiler.h"
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
#include "lobject.h"
#include "decompile.h"
#include "proto.h"

extern lua_State* glstate;

@interface LuaDecompiler () {
    lua_State *l;
}

@end

@implementation LuaDecompiler

- (instancetype)init {
    self = [super init];
    if (self) {
        InitOperators();
        l = luaL_newstate();
        luaL_openlibs(l);
    }
    return self;
}

- (void)dealloc {
    lua_close(l);
}

- (NSData *)decompileData:(NSData *)data {
    glstate = l;

    luaL_loadbuffer(l, data.bytes, data.length, nil);

    Closure *c = (Closure *)lua_topointer(l, -1);
    Proto *f = c->l.p;
    char *code = luaU_decompile(f, 0);

    NSData *output = [NSData dataWithBytesNoCopy:code length:strlen(code)];
    return output;
}

@end
