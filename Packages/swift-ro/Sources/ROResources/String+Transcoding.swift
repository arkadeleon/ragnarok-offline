//
//  String+Transcoding.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2024/4/1.
//

extension StringProtocol {
    func transcoding(from: String.Encoding, to: String.Encoding) -> String? {
        data(using: from).flatMap { data in
            String(data: data, encoding: to)
        }
    }
}
