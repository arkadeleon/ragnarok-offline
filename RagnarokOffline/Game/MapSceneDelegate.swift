//
//  MapSceneDelegate.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/3/27.
//

import RONetwork

protocol MapSceneDelegate: AnyObject {
    func mapSceneDidFinishLoading(_ scene: any MapSceneProtocol)
    func mapScene(_ scene: any MapSceneProtocol, didTapTileAt position: SIMD2<Int>)
    func mapScene(_ scene: any MapSceneProtocol, didTapMapObject object: MapObject)
    func mapScene(_ scene: any MapSceneProtocol, didTapMapObjectWith objectID: UInt32)
    func mapScene(_ scene: any MapSceneProtocol, didTapMapItem item: MapItem)
}
