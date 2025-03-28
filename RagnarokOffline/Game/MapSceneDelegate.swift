//
//  MapSceneDelegate.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/3/27.
//

protocol MapSceneDelegate: AnyObject {
    func mapSceneDidFinishLoading(_ scene: any MapSceneProtocol)
    func mapScene(_ scene: any MapSceneProtocol, didTapTileAt position: SIMD2<Int16>)
    func mapScene(_ scene: any MapSceneProtocol, didTapMapObjectWith objectID: UInt32)
}
