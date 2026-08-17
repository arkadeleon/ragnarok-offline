//
//  FogParameterTable.swift
//  RagnarokResources
//
//  Created by Leon Li on 2026/8/16.
//

import Foundation

public struct FogColor: Sendable {
    public var alpha: Float
    public var red: Float
    public var green: Float
    public var blue: Float

    public var rgb: SIMD3<Float> {
        SIMD3<Float>(red, green, blue)
    }
}

public struct FogParameter: Sendable {
    public var near: Float
    public var far: Float
    public var color: FogColor
    public var factor: Float
}

final public class FogParameterTable: Resource {
    let fogParametersByMapName: [String : FogParameter]

    init(fogParametersByMapName: [String : FogParameter] = [:]) {
        self.fogParametersByMapName = fogParametersByMapName
    }

    // The map name should contain rsw suffix.
    public func fogParameter(forMapName mapName: String) -> FogParameter? {
        fogParametersByMapName[mapName.lowercased()]
    }
}

extension ResourceManager {
    public func fogParameterTable() async -> FogParameterTable {
        await cache.resource(forIdentifier: "FogParameterTable") { [self] in
            let data: Data
            do {
                data = try await contentsOfResource(at: ["data", "fogparametertable.txt"])
            } catch {
                logger.warning("\(error)")
                return FogParameterTable()
            }

            guard let contents = String(data: data, encoding: .isoLatin1) else {
                return FogParameterTable()
            }

            let fields = contents
                .components(separatedBy: "\r\n")
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty && !$0.starts(with: "//") }
                .compactMap { $0.components(separatedBy: "#").first }

            var fogParametersByMapName: [String : FogParameter] = [:]

            for index in stride(from: 0, to: fields.count - 4, by: 5) {
                let mapName = fields[index]
                let near = Float(fields[index + 1])
                let far = Float(fields[index + 2])
                let hexColor = fields[index + 3].lowercased()
                let factor = Float(fields[index + 4])

                guard !mapName.isEmpty,
                      let near,
                      let far,
                      hexColor.hasPrefix("0x"),
                      let color = UInt32(String(hexColor.dropFirst(2)), radix: 16),
                      let factor else {
                    continue
                }

                let fogColor = FogColor(
                    alpha: Float((color >> 24) & 0xFF) / 255,
                    red: Float((color >> 16) & 0xFF) / 255,
                    green: Float((color >> 8) & 0xFF) / 255,
                    blue: Float(color & 0xFF) / 255
                )
                let fogParameter = FogParameter(
                    near: near,
                    far: far,
                    color: fogColor,
                    factor: factor
                )
                fogParametersByMapName[mapName] = fogParameter
            }

            return FogParameterTable(fogParametersByMapName: fogParametersByMapName)
        }
    }
}
