//
//  SPRPreviewViewController.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/12/19.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import CoreGraphics
import UIKit
import RagnarokOfflineFileFormats
import RagnarokOfflineGraphics
import RagnarokOfflineFileSystem

class SPRPreviewViewController: UIViewController {
    struct Sprite: Hashable {
        var index: Int
        var size: CGSize
        var image: StillImage

        func hash(into hasher: inout Hasher) {
            index.hash(into: &hasher)
        }
    }

    let file: File

    private var collectionView: UICollectionView!
    private var activityIndicatorView: UIActivityIndicatorView!

    private var diffableDataSource: UICollectionViewDiffableDataSource<Int, Sprite>!

    init(file: File) {
        self.file = file
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addActionCollectionView()
        addActivityIndicatorView()

        activityIndicatorView.startAnimating()

        Task {
            let sprites = await loadSprites()
            await updateSnapshot(with: sprites, animatingDifferences: false)
            activityIndicatorView.stopAnimating()
        }
    }

    private func addActionCollectionView() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 32
        flowLayout.minimumInteritemSpacing = 16
        flowLayout.sectionInset = UIEdgeInsets(top: 32, left: 32, bottom: 32, right: 32)

        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.delegate = self

        let cellRegistration = UICollectionView.CellRegistration<ImageCollectionViewCell, Sprite> { cell, indexPath, sprite in
            cell.imageView.image = UIImage(cgImage: sprite.image.image)
        }

        diffableDataSource = UICollectionViewDiffableDataSource<Int, Sprite>(collectionView: collectionView) { collectionView, indexPath, sprite in
            let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: sprite)
            return cell
        }
        collectionView.dataSource = diffableDataSource

        view.addSubview(collectionView)
    }

    private func addActivityIndicatorView() {
        activityIndicatorView = UIActivityIndicatorView(style: .medium)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(activityIndicatorView)

        activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }

    nonisolated private func loadSprites() async -> [Sprite] {
        guard let data = file.contents() else {
            return []
        }

        guard let spr = try? SPR(data: data) else {
            return []
        }

        let images = (0..<spr.sprites.count).compactMap { index in
            spr.image(forSpriteAt: index)
        }

        let size = images.reduce(CGSize(width: 80, height: 80)) { size, image in
            CGSize(
                width: max(size.width, CGFloat(image.image.width)),
                height: max(size.height, CGFloat(image.image.height))
            )
        }

        let sprites = images.enumerated().map { (index, image) in
            Sprite(index: index, size: size, image: image)
        }
        return sprites
    }

    nonisolated private func updateSnapshot(with sprites: [Sprite], animatingDifferences: Bool) async {
        var snapshot = NSDiffableDataSourceSnapshot<Int, Sprite>()

        snapshot.appendSections([0])
        snapshot.appendItems(sprites, toSection: 0)

        await diffableDataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
}

extension SPRPreviewViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        guard let indexPath = indexPaths.first,
              let cell = collectionView.cellForItem(at: indexPath),
              let sprite = diffableDataSource.itemIdentifier(for: indexPath)
        else {
            return nil
        }

        let activityItem = StillImageActivityItem(stillImage: sprite.image, filename: file.name, index: indexPath.item)

        let shareAction = UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up")) { _ in
            let activityViewController = UIActivityViewController(activityItems: [activityItem], applicationActivities: nil)
            activityViewController.modalPresentationStyle = .popover
            activityViewController.popoverPresentationController?.sourceView = cell
            activityViewController.popoverPresentationController?.sourceRect = cell.bounds
            self.present(activityViewController, animated: true)
        }

        let configuration = UIContextMenuConfiguration(actionProvider: { _ in
            UIMenu(children: [shareAction])
        })
        return configuration
    }
}

extension SPRPreviewViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sprite = diffableDataSource.itemIdentifier(for: indexPath)
        return sprite?.size ?? .zero
    }
}
