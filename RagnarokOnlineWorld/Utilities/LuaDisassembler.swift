//
//  LuaDisassembler.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/8/4.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import Foundation

enum LuaDisassemblerError: Error {
    case fileMissing
}

class LuaDisassembler {

    let l: OpaquePointer!

    init() {
        l = luaL_newstate()
        luaL_openlibs(l)
    }

    deinit {
        lua_close(l)
    }

    func disassemble(data: Data) throws -> Data {
        guard let chunkspyURL = Bundle.main.url(forResource: "chunkspy", withExtension: "lua") else {
            throw LuaDisassemblerError.fileMissing
        }

        luaL_loadfile(l, chunkspyURL.path)
        lua_pcall(l, 0, 0, 0)

        let baseURL = try FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let sourceURL = baseURL.appendingPathComponent("temp.luac")
        let destinationURL = baseURL.appendingPathComponent("temp.lst")
        
        try data.write(to: sourceURL)

        luaL_loadstring(l, """
        function DisassembleFile(src, dest)
            config.OUTPUT_FILE = dest
            OutputInit()
            ChunkSpy_DoFiles({src})
            OutputExit()
        end
        """)
        lua_pcall(l, 0, 0, 0)

        lua_getfield(l, LUA_GLOBALSINDEX, "DisassembleFile")
        lua_pushstring(l, sourceURL.path)
        lua_pushstring(l, destinationURL.path)
        lua_pcall(l, 2, 0, 0)
        lua_settop(l, -2)

        let result = try Data(contentsOf: destinationURL)

        try FileManager.default.removeItem(at: sourceURL)
        try FileManager.default.removeItem(at: destinationURL)

        return result
    }
}
