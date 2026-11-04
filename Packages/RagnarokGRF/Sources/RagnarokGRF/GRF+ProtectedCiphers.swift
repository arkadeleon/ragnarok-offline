//
//  GRF+ProtectedCiphers.swift
//  RagnarokGRF
//
//  Created by Leon Li on 2026/10/29.
//

// CHAM uses 80 rounds and big-endian words. ThreeWay uses 11 rounds. IDEA and RC6
// only encrypt blocks here: the format uses their output as XOR masks and CFB streams.
extension GRF {
    enum ProtectedCiphers {
        static func decryptChamCBC(_ data: inout [UInt8], offset: Int, length: Int, key: [UInt8], iv: [UInt8]) throws {
            guard length % 16 == 0 else {
                throw GRFError.invalidProtectedData("Incomplete protected GRF CHAM block.")
            }

            var keys = [UInt32](repeating: 0, count: 8)
            for i in 0..<4 {
                let value = key.bigEndianUInt32(at: i * 4)
                keys[i] = value ^ rotateLeft(value, 1) ^ rotateLeft(value, 8)
                keys[(i + 4) ^ 1] = value ^ rotateLeft(value, 1) ^ rotateLeft(value, 11)
            }

            var previous = iv
            var words = [UInt32](repeating: 0, count: 4)
            for position in stride(from: offset, to: offset + length, by: 16) {
                let encrypted = Array(data[position..<(position + 16)])
                for i in 0..<4 {
                    words[i] = encrypted.bigEndianUInt32(at: i * 4)
                }
                for round in stride(from: 79, through: 0, by: -1) {
                    let i = round % 4
                    let odd = round & 1 != 0
                    words[i] = (rotateRight(words[i], odd ? 1 : 8) &- (rotateLeft(words[(i + 1) % 4], odd ? 8 : 1) ^ keys[round % 8])) ^ UInt32(round)
                }
                for i in 0..<4 {
                    data.setBigEndianUInt32(words[i], at: position + i * 4)
                }
                for i in 0..<16 {
                    data[position + i] ^= previous[i]
                }
                previous = encrypted
            }
        }

        static func decryptThreeWayCFB(_ data: inout [UInt8], offset: Int, length: Int, key: [UInt8], iv: [UInt8]) throws {
            guard length % 12 == 0 else {
                throw GRFError.invalidProtectedData("Incomplete protected GRF ThreeWay block.")
            }

            var previous = iv
            for position in stride(from: offset, to: offset + length, by: 12) {
                let encrypted = Array(data[position..<(position + 12)])
                let stream = threeWayEncrypt(key: key, block: previous)
                for i in 0..<12 {
                    data[position + i] ^= stream[i]
                }
                previous = encrypted
            }
        }

        static func decryptBodyTail(cipher: Int, parameters: [UInt8], filenameHash: [UInt8], outputHash: [UInt8], data: inout [UInt8], offset: Int) throws {
            let mask = cipher == 128
                ? ideaMask(key: outputHash, input: filenameHash, iv: Array(parameters[49..<57]))
                : ideaMask(key: filenameHash, input: outputHash, iv: Array(parameters[49..<57]))
            let length = data.count - offset

            if cipher == 128 {
                let start = length < 3072 ? 0 : 2048
                let size = length < 3072 ? length / 16 * 16 : 1024
                try AES.decryptCBC(&data, offset: offset + start, length: size, key: Array(parameters[44..<60]), iv: Array(parameters[28..<44]))
            } else {
                let keys = rc6Keys(Array(parameters[24..<40]))
                var previous = Array(parameters[40..<56])
                let size = min(length / 16 * 16, 1024)
                for position in stride(from: offset, to: offset + size, by: 16) {
                    let encrypted = Array(data[position..<(position + 16)])
                    let stream = rc6Encrypt(previous, keys: keys)
                    for i in 0..<16 {
                        data[position + i] ^= stream[i]
                    }
                    previous = encrypted
                }
            }

            for i in 0..<length {
                data[offset + i] ^= mask[i % 16]
            }
        }

        static func decryptLegacyTail(cipher: Int, parameters: [UInt8], filenameHash: [UInt8], outputHash: [UInt8], data: inout [UInt8], offset: Int, compressedLength: Int) throws {
            let length = min(compressedLength, 1024)
            let encryptedLength = (length / 16 + 1) * 16
            let tailLength = data.count - offset
            guard tailLength >= encryptedLength && tailLength - encryptedLength == compressedLength - length else {
                throw GRFError.invalidProtectedData("Protected GRF AES body padding size mismatch.")
            }

            let key: [UInt8]
            let iv: [UInt8]
            let mask: [UInt8]
            if cipher == 5 {
                key = Array(parameters[0..<16])
                iv = Array(parameters[16..<32])
                mask = ideaMask(key: filenameHash, input: outputHash, iv: Array(parameters[48..<56]))
            } else {
                key = Array(parameters[28..<44])
                iv = Array(parameters[44..<60])
                mask = ideaMask(key: outputHash, input: filenameHash, iv: Array(parameters[52..<60]))
            }

            try AES.decryptCBC(&data, offset: offset, length: encryptedLength, key: key, iv: iv)

            let padding = Int(data[offset + encryptedLength - 1])
            guard padding >= 1 && padding <= 16 && encryptedLength - padding == length else {
                throw GRFError.invalidProtectedData("Invalid protected GRF AES body PKCS#7 padding.")
            }
            for i in length..<encryptedLength where data[offset + i] != padding {
                throw GRFError.invalidProtectedData("Invalid protected GRF AES body PKCS#7 padding.")
            }

            data.replaceSubrange(
                (offset + length)..<(offset + length + tailLength - encryptedLength),
                with: data[(offset + encryptedLength)..<(offset + tailLength)]
            )
            for i in 0..<(compressedLength - length) {
                data[offset + length + i] ^= mask[i % 16]
            }
        }

        static func decryptChamTail(parameters: [UInt8], seededNameHash: [UInt8], outputHash: [UInt8], data: inout [UInt8], offset: Int) throws {
            let seed = UInt64(seededNameHash.littleEndianUInt32(at: 8)) | UInt64(seededNameHash.littleEndianUInt32(at: 12)) << 32
            let key = GRF.ProtectedDecoder.nativeHash(Array(parameters[0..<60]), seed: seed)
            let length = data.count - offset
            let fullLength = length / 16 * 16

            try decryptChamCBC(&data, offset: offset, length: min(fullLength, 1024), key: key, iv: outputHash)

            var previous = outputHash
            for position in stride(from: offset, to: offset + fullLength, by: 16) {
                let original = Array(data[position..<(position + 16)])
                for i in 0..<16 {
                    let rotated = (i + 12) % 16
                    data[position + i] = original[rotated] ^ seededNameHash[rotated] ^ previous[i]
                }
                previous = original
            }
            for i in 0..<(length - fullLength) {
                data[offset + fullLength + i] ^= seededNameHash[i] ^ previous[i]
            }
        }

        // MARK: - ThreeWay

        private static func threeWayTheta(_ a: inout UInt32, _ b: inout UInt32, _ c: inout UInt32) {
            let mix = rotateLeft(a ^ b ^ c, 16) ^ rotateLeft(a ^ b ^ c, 8)
            let u = (a << 24) ^ (c >> 8) ^ (b << 8) ^ (a >> 24)
            let v = (b << 24) ^ (a >> 8) ^ (c << 8) ^ (b >> 24)
            a ^= mix ^ u
            b ^= mix ^ v
            c ^= mix ^ (u >> 16) ^ (v << 16)
        }

        private static func threeWayEncrypt(key: [UInt8], block: [UInt8]) -> [UInt8] {
            let k0 = key.bigEndianUInt32(at: 0)
            let k1 = key.bigEndianUInt32(at: 4)
            let k2 = key.bigEndianUInt32(at: 8)
            var a = block.bigEndianUInt32(at: 0)
            var b = block.bigEndianUInt32(at: 4)
            var c = block.bigEndianUInt32(at: 8)
            var rc: UInt32 = 0x0b0b

            for _ in 0..<11 {
                a ^= k0 ^ (rc << 16)
                b ^= k1
                c ^= k2 ^ rc
                threeWayTheta(&a, &b, &c)
                let u = rotateLeft(a, 22)
                let v = rotateLeft(c, 1)
                a = rotateLeft(u ^ (b | ~v), 1)
                c = rotateLeft(v ^ (u | ~b), 22)
                b ^= v | ~u
                rc <<= 1
                if rc & 0x10000 != 0 {
                    rc ^= 0x11011
                }
            }
            a ^= k0 ^ (rc << 16)
            b ^= k1
            c ^= k2 ^ rc
            threeWayTheta(&a, &b, &c)

            var result = [UInt8](repeating: 0, count: 12)
            result.setBigEndianUInt32(a, at: 0)
            result.setBigEndianUInt32(b, at: 4)
            result.setBigEndianUInt32(c, at: 8)
            return result
        }

        // MARK: - IDEA

        private static func ideaMultiply(_ a: UInt16, _ b: UInt16) -> UInt16 {
            let left: UInt64 = a == 0 ? 65536 : UInt64(a)
            let right: UInt64 = b == 0 ? 65536 : UInt64(b)
            return UInt16(truncatingIfNeeded: left * right % 65537)
        }

        private static func ideaKeys(_ key: [UInt8]) -> [UInt16] {
            var value = key
            var keys = [UInt16](repeating: 0, count: 52)
            for i in 0..<52 {
                if i > 0 && i % 8 == 0 {
                    // Rotates the 128-bit big-endian key left by 25 bits.
                    value = (0..<16).map { j in (value[(j + 3) % 16] << 1) | (value[(j + 4) % 16] >> 7) }
                }
                let offset = i % 8 * 2
                keys[i] = UInt16(value[offset]) << 8 | UInt16(value[offset + 1])
            }
            return keys
        }

        private static func ideaEncrypt(_ block: [UInt8], keys: [UInt16]) -> [UInt8] {
            var a = UInt16(block[0]) << 8 | UInt16(block[1])
            var b = UInt16(block[2]) << 8 | UInt16(block[3])
            var c = UInt16(block[4]) << 8 | UInt16(block[5])
            var d = UInt16(block[6]) << 8 | UInt16(block[7])

            for i in stride(from: 0, to: 48, by: 6) {
                a = ideaMultiply(a, keys[i])
                b &+= keys[i + 1]
                c &+= keys[i + 2]
                d = ideaMultiply(d, keys[i + 3])
                let e = ideaMultiply(a ^ c, keys[i + 4])
                let f = ideaMultiply((b ^ d) &+ e, keys[i + 5])
                let g = e &+ f
                let oldB = b
                a ^= f
                b = c ^ f
                c = oldB ^ g
                d ^= g
            }

            let words = [ideaMultiply(a, keys[48]), c &+ keys[49], b &+ keys[50], ideaMultiply(d, keys[51])]
            return words.flatMap { [UInt8($0 >> 8), UInt8(truncatingIfNeeded: $0)] }
        }

        private static func ideaMask(key: [UInt8], input: [UInt8], iv: [UInt8]) -> [UInt8] {
            let keys = ideaKeys(key)
            let first = ideaEncrypt((0..<8).map { input[$0] ^ iv[$0] }, keys: keys)
            let second = ideaEncrypt((0..<8).map { input[8 + $0] ^ first[$0] }, keys: keys)
            return first + second
        }

        // MARK: - RC6

        private static func rc6Keys(_ key: [UInt8]) -> [UInt32] {
            var words = (0..<4).map { key.littleEndianUInt32(at: $0 * 4) }
            var keys = (0..<44).map { 0xb7e15163 &+ UInt32($0) &* 0x9e3779b9 }
            var a: UInt32 = 0
            var b: UInt32 = 0
            var i = 0
            var j = 0
            for _ in 0..<132 {
                keys[i] = rotateLeft(keys[i] &+ a &+ b, 3)
                a = keys[i]
                words[j] = rotateLeft(words[j] &+ a &+ b, Int(a &+ b))
                b = words[j]
                i = (i + 1) % 44
                j = (j + 1) % 4
            }
            return keys
        }

        private static func rc6Encrypt(_ block: [UInt8], keys: [UInt32]) -> [UInt8] {
            var a = block.littleEndianUInt32(at: 0)
            var b = block.littleEndianUInt32(at: 4) &+ keys[0]
            var c = block.littleEndianUInt32(at: 8)
            var d = block.littleEndianUInt32(at: 12) &+ keys[1]

            for i in 1...20 {
                let t = rotateLeft(b &* (b &* 2 &+ 1), 5)
                let u = rotateLeft(d &* (d &* 2 &+ 1), 5)
                a = rotateLeft(a ^ t, Int(u)) &+ keys[2 * i]
                c = rotateLeft(c ^ u, Int(t)) &+ keys[2 * i + 1]
                (a, b, c, d) = (b, c, d, a)
            }

            var result = [UInt8](repeating: 0, count: 16)
            result.setLittleEndianUInt32(a &+ keys[42], at: 0)
            result.setLittleEndianUInt32(b, at: 4)
            result.setLittleEndianUInt32(c &+ keys[43], at: 8)
            result.setLittleEndianUInt32(d, at: 12)
            return result
        }

        private static func rotateLeft(_ value: UInt32, _ count: Int) -> UInt32 {
            (value << (count & 31)) | (value >> ((32 - count) & 31))
        }

        private static func rotateRight(_ value: UInt32, _ count: Int) -> UInt32 {
            rotateLeft(value, 32 - count)
        }
    }
}
