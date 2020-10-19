//
//  SpritePreviewViewController.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/7/1.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import UIKit

private let frameCellReuseIdentifier = "FrameCell"

class SpritePreviewViewController: UIViewController {

    let previewItem: PreviewItem

    private var frames: [CGImage?] = []

    private var framesView: UICollectionView!

    init(previewItem: PreviewItem) {
        self.previewItem = previewItem
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = previewItem.title

        view.backgroundColor = .systemBackground

        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        layout.itemSize = CGSize(width: 80, height: 80)
        layout.sectionInset = UIEdgeInsets(top: 16, left: 32, bottom: 16, right: 32)

        framesView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        framesView.translatesAutoresizingMaskIntoConstraints = false
        framesView.backgroundColor = .secondarySystemBackground
        framesView.dataSource = self
        framesView.showsVerticalScrollIndicator = false
        framesView.showsHorizontalScrollIndicator = false
        framesView.register(SpriteFrameCell.self, forCellWithReuseIdentifier: frameCellReuseIdentifier)
        view.addSubview(framesView)

        framesView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        framesView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        framesView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        framesView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        loadPreviewItem()
    }

    private func loadPreviewItem() {
        DispatchQueue.global().async {
            guard let data = try? self.previewItem.data() else {
                return
            }

            let loader = DocumentLoader()
            guard let document = try? loader.load(SPRDocument.self, from: data) else {
                return
            }

            var frames: [CGImage?] = []
            for index in 0..<document.frames.count {
                let frame = document.imageForFrame(at: index)
                frames.append(frame)
            }
            self.frames = frames

            DispatchQueue.main.async {
                self.framesView.reloadData()
            }
        }
    }
}

extension SpritePreviewViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return frames.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: frameCellReuseIdentifier, for: indexPath) as! SpriteFrameCell
        cell.frameView.image = frames[indexPath.item].flatMap { UIImage(cgImage: $0) }
        return cell
    }
}
