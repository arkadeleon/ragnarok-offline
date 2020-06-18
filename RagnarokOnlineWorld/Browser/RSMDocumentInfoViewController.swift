//
//  RSMDocumentInfoViewController.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/6/18.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import UIKit

class RSMDocumentInfoViewController: UIViewController {

    let document: RSMDocument

    private var textView: UITextView!

    init(document: RSMDocument) {
        self.document = document
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Info"

        view.backgroundColor = .systemBackground

        textView = UITextView(frame: view.bounds)
        textView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(textView)

        document.open { _ in
            var text = ""

            text.append("Textures:\n")

            for texture in self.document.textures {
                text.append(texture)
                text.append("\n")
            }

            text.append("\n")

            for node in self.document.nodes {
                text.append("Name: \(node.name)\n")
                text.append("Parent name: \(node.parentname)\n")

                text.append("Textures: \(node.textures)\n")

                text.append("Mat3: \(node.mat3)\n")
                text.append("Offset: \(node.offset)\n")
                text.append("Pos: \(node.pos)\n")
                text.append("Rot angle: \(node.rotangle)\n")
                text.append("Rot Axis: \(node.rotaxis)\n")
                text.append("Scale: \(node.scale)\n")

                text.append("Vertices: \(node.vertices)\n")
                text.append("T Vertices: \(node.vertices)\n")
                text.append("Faces: \(node.faces)\n")
                text.append("Position keyframes: \(node.positionKeyframes)\n")
                text.append("Rotation keyframes: \(node.rotationKeyframes)\n")

                text.append("\n")
            }

            self.textView.text = text

            self.document.close()
        }
    }
}
