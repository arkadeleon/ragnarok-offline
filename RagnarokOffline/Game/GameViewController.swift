//
//  GameViewController.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/11/20.
//

import MetalKit
import UIKit

class GameViewController: UIViewController {
    private var mtkView: MTKView!

    private var renderer: GameRenderer!

    private var magnification: CGFloat = 1
    private var dragTranslation: CGPoint = .zero

    override func viewDidLoad() {
        super.viewDidLoad()

        let device = MTLCreateSystemDefaultDevice()!
        renderer = GameRenderer(device: device)

        mtkView = MTKView()
        mtkView.translatesAutoresizingMaskIntoConstraints = false
        mtkView.isOpaque = false
        mtkView.delegate = renderer
        mtkView.device = renderer.device
        mtkView.colorPixelFormat = renderer.colorPixelFormat
        mtkView.depthStencilPixelFormat = renderer.depthStencilPixelFormat
        mtkView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        view.addSubview(mtkView)

        mtkView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        mtkView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        mtkView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        mtkView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        mtkView.addGestureRecognizer(pinchGestureRecognizer)

        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        mtkView.addGestureRecognizer(panGestureRecognizer)
    }

    @objc private func handlePinch(_ pinchGestureRecognizer: UIPinchGestureRecognizer) {
        switch pinchGestureRecognizer.state {
        case .changed:
            let magnification = magnification * pinchGestureRecognizer.scale
            renderer.scene.camera.update(magnification: magnification, dragTranslation: dragTranslation)
        case .ended:
            magnification = magnification * pinchGestureRecognizer.scale
        default:
            break
        }
    }

    @objc private func handlePan(_ panGestureRecognizer: UIPanGestureRecognizer) {
        switch panGestureRecognizer.state {
        case .changed:
            let translation = panGestureRecognizer.translation(in: panGestureRecognizer.view)
            let dragTranslation = CGPoint(x: dragTranslation.x + translation.x, y: dragTranslation.y + translation.y)
            renderer.scene.camera.update(magnification: magnification, dragTranslation: dragTranslation)
        case .ended:
            let translation = panGestureRecognizer.translation(in: panGestureRecognizer.view)
            dragTranslation = CGPoint(x: dragTranslation.x + translation.x, y: dragTranslation.y + translation.y)
        default:
            break
        }
    }
}
