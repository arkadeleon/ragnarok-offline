//
//  ComposedSprite.Configuration.swift
//  SpriteRendering
//
//  Created by Leon Li on 2025/2/14.
//

import Constants

extension ComposedSprite {
    public struct Configuration: Equatable, Sendable {
        public let job: UniformJob
        public var gender: Gender
        public var hairStyle: Int
        public var hairColor: Int
        public var clothesColor: Int
        public var weapon: Int
        public var shield: Int
        public var headgears: [Int]
        public var garment: Int
        public var outfit: Int
        public var madoType: MadoType

        public init(jobID: Int) {
            self.job = UniformJob(rawValue: jobID)
            self.gender = .male
            self.hairStyle = 1
            self.hairColor = -1
            self.clothesColor = -1
            self.weapon = 0
            self.shield = 0
            self.headgears = []
            self.garment = 0
            self.outfit = 0
            self.madoType = .robot
        }
    }
}
