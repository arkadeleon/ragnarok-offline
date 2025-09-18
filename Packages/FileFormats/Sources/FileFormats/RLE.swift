//
//  RLE.swift
//  FileFormats
//
//  Created by Leon Li on 2023/11/15.
//

import Foundation

/// Run-Length Encoding
struct RLE {
    func decompress(_ data: Data) -> Data {
        var decompressedData = Data()

        var index = 0
        while index < data.count {
            let c = data[index]
            index += 1

            decompressedData.append(c)

            if c == 0 {
                let count = data[index]
                index += 1

                if count == 0 {
                    decompressedData.append(count)
                } else {
                    for _ in 1..<count {
                        decompressedData.append(c)
                    }
                }
            }
        }

        return decompressedData
    }
}
