//
//  PlatformMapScene.swift
//  RagnarokGame
//
//  Created by Leon Li on 2026/5/30.
//

#if os(visionOS)
public typealias RealityMapScene = MapScene
#else
public typealias MetalMapScene = MapScene
#endif
