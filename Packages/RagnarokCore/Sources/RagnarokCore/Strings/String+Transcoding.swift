//
//  String+Transcoding.swift
//  RagnarokCore
//
//  Created by Leon Li on 2024/4/1.
//

import Foundation

/// Converts a string from CP949 encoding to ISO Latin-1 encoding.
public func K2L(_ k: String) -> String {
    k.transcoding(from: .dosKorean, to: .isoLatin1) ?? k
}

/// Converts a string from ISO Latin-1 encoding to CP949 encoding.
public func L2K(_ l: String) -> String {
    l.transcoding(from: .isoLatin1, to: .dosKorean) ?? l
}

extension StringProtocol {
    public func transcoding(from sourceEncoding: String.Encoding, to destinationEncoding: String.Encoding) -> String? {
        data(using: sourceEncoding).flatMap { data in
            String(data: data, encoding: destinationEncoding)
        }
    }
}
