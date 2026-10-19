//
//  ElementalAttributeDamageAdjustmentDatabase.swift
//  RagnarokDatabase
//
//  Created by Leon Li on 2026/10/19.
//

import Foundation
import RapidYAML

final public class ElementalAttributeDamageAdjustmentDatabase: Sendable {
    public let baseURL: URL
    public let mode: DatabaseMode

    public init(baseURL: URL, mode: DatabaseMode) {
        self.baseURL = baseURL
        self.mode = mode
    }

    public func elementalAttributeDamageAdjustments() async throws -> [ElementalAttributeDamageAdjustment] {
        metric.beginMeasuring("Load elemental attribute damage adjustments")

        let decoder = YAMLDecoder()

        let url = baseURL.appending(path: "db/\(mode.path)/attr_fix.yml")
        let data = try Data(contentsOf: url)
        let elementalAttributeDamageAdjustments = try decoder.decode(ListNode<ElementalAttributeDamageAdjustment>.self, from: data).body

        metric.endMeasuring("Load elemental attribute damage adjustments")

        return elementalAttributeDamageAdjustments
    }
}
