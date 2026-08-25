//
//  String+RandomNumber.swift
//  RagnarokRenderAssets
//
//  Created by Leon Li on 2026/8/25.
//

extension String {
    // Only STR file names and sound names use %d to select between numbered
    // variants, such as windhit1.str through windhit3.str.
    func replacingRandomNumber(in range: ClosedRange<Int>?) -> String {
        guard let range else {
            return self
        }
        return replacingOccurrences(of: "%d", with: "\(Int.random(in: range))")
    }
}
