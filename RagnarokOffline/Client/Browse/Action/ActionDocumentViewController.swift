//
//  ActionDocumentViewController.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/8/13.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import UIKit

private let animationCellReuseIdentifier = "AnimationCell"

class ActionDocumentViewController: UIViewController {

    let document: DocumentWrapper

    private var animations: [(images: [UIImage], duration: Double)] = []

    private var animationsView: UICollectionView!

    init(document: DocumentWrapper) {
        self.document = document
        super.init(nibName: nil, bundle: nil)
        title = document.name
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        layout.itemSize = CGSize(width: 80, height: 80)
        layout.sectionInset = UIEdgeInsets(top: 16, left: 32, bottom: 16, right: 32)

        animationsView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        animationsView.translatesAutoresizingMaskIntoConstraints = false
        animationsView.backgroundColor = .systemBackground
        animationsView.dataSource = self
        animationsView.delegate = self
        animationsView.showsVerticalScrollIndicator = false
        animationsView.showsHorizontalScrollIndicator = false
        animationsView.register(ActionAnimationCell.self, forCellWithReuseIdentifier: animationCellReuseIdentifier)
        view.addSubview(animationsView)

        animationsView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        animationsView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        animationsView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        animationsView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        loadDocumentContents()
    }

    private func loadDocumentContents() {
        DispatchQueue.global().async {
            guard case let .grfNode(grf, node) = self.document,
                  let actData = self.document.contents()
            else {
                return
            }

            let sprName = (node.name as NSString).deletingPathExtension.appending(".spr")
            guard let sprData = grf.node(atPath: sprName)?.contents else {
                return
            }

            let loader = DocumentLoader()
            guard let actDocument = try? loader.load(ACTDocument.self, from: actData),
                  let sprDocument = try? loader.load(SPRDocument.self, from: sprData)
            else {
                return
            }

            var frames: [CGImage?] = []
            for index in 0..<sprDocument.frames.count {
                let frame = sprDocument.imageForFrame(at: index)
                frames.append(frame)
            }

            var animations: [(images: [UIImage], duration: Double)] = []
            for index in 0..<actDocument.actions.count {
                let animation = actDocument.animationForAction(at: index, with: frames)
                animations.append(animation)
            }
            self.animations = animations

            DispatchQueue.main.async {
                self.animationsView.reloadData()
            }
        }
    }
}

extension ActionDocumentViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return animations.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: animationCellReuseIdentifier, for: indexPath) as! ActionAnimationCell
        cell.frameView.image = animations[indexPath.item].images.first
        return cell
    }
}

extension ActionDocumentViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ActionAnimationCell?
        cell?.frameView.animationImages = animations[indexPath.item].images
        cell?.frameView.animationDuration = animations[indexPath.item].duration
        cell?.frameView.startAnimating()
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ActionAnimationCell?
        cell?.frameView.stopAnimating()
    }
}
