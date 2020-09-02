//
//  ModelPreviewViewController.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/5/12.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import UIKit
import SceneKit
import SceneKit.ModelIO

class ModelPreviewViewController: UIViewController {

    let previewItem: PreviewItem

    private var scnView: SCNView!

    init(previewItem: PreviewItem) {
        self.previewItem = previewItem
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        scnView = SCNView()
        view = scnView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = previewItem.title
        edgesForExtendedLayout = []

        view.backgroundColor = .tertiarySystemBackground

        loadPreviewItem()
    }

    private func loadPreviewItem() {
        DispatchQueue.global().async {
            guard let entry = self.previewItem as? Entry,
                  let data = try? self.previewItem.data()
            else {
                return
            }

            let loader = DocumentLoader()
            guard let document = try? loader.load(RSMDocument.self, from: data) else {
                return
            }

            let materials = document.textures.map { textureName -> MDLMaterial? in
                guard let textureData = try? entry.tree.contentsOfEntry(withName: "data\\texture\\" + textureName) else {
                    return nil
                }
                return MDLMaterial(textureName: textureName, textureData: textureData)
            }

            DispatchQueue.main.async {
                let asset = MDLAsset(document: document, materials: materials)
                let scene = SCNScene(mdlAsset: asset)

//                let cameraNode = SCNNode()
//                cameraNode.camera = SCNCamera()
//                cameraNode.position = SCNVector3(x: 0, y: 0, z: 30)
//                scene.rootNode.addChildNode(cameraNode)

//                let action = SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 2))
//                scene.rootNode.childNodes.first?.runAction(action)

                self.scnView.scene = scene
                self.scnView.showsStatistics = true
                self.scnView.allowsCameraControl = true
                self.scnView.autoenablesDefaultLighting = true
            }
        }
    }
}
