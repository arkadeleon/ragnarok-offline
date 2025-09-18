//
//  String+Transcoding.swift
//  TextEncoding
//
//  Created by Leon Li on 2024/4/1.
//

import Foundation

public func K2L(_ k: String) -> String {
    k.transcoding(from: .koreanEUC, to: .isoLatin1) ?? k
}

public func L2K(_ l: String) -> String {
    l.transcoding(from: .isoLatin1, to: .koreanEUC) ?? l
}

extension StringProtocol {
    public func transcoding(from: String.Encoding, to: String.Encoding) -> String? {
        data(using: from).flatMap { data in
            String(data: data, encoding: to)
        }
    }
}
