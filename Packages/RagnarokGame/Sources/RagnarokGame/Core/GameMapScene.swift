//
//  GameMapScene.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/5/30.
//

import Foundation

@MainActor protocol GameMapScene: AnyObject {
    var mapName: String { get }

    func load(progress: Progress) async
    func unload()
}
