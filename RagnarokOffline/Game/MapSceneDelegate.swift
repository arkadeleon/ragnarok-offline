//
//  MapSceneDelegate.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/3/27.
//

protocol MapSceneDelegate: AnyObject {
    func mapSceneDidFinishLoading(_ scene: any MapSceneProtocol)
    func mapScene(_ scene: any MapSceneProtocol, didTapPosition position: SIMD2<Int16>)
}
