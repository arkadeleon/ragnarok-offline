//
//  ACTPreviewViewController.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/11/15.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import CoreGraphics
import UIKit

class ACTPreviewViewController: UIViewController {
    let file: File

    private var collectionView: UICollectionView!
    private var activityIndicatorView: UIActivityIndicatorView!

    private var diffableDataSource: UICollectionViewDiffableDataSource<Section, AnimatedImage>!

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

        Task(priority: .userInitiated) { [weak self] in
            if let animatedImages = await self?.loadAnimatedImages() {
                await self?.updateSnapshot(animatedImages: animatedImages, animatingDifferences: false)
            }
            self?.activityIndicatorView.stopAnimating()
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

        let cellRegistration = UICollectionView.CellRegistration<ACTActionCollectionViewCell, AnimatedImage> { cell, indexPath, animatedImage in
            cell.imageView.image = UIImage.animatedImage(with: animatedImage.images.map(UIImage.init), duration: animatedImage.delay * CGFloat(animatedImage.images.count))
        }

        diffableDataSource = UICollectionViewDiffableDataSource<Section, AnimatedImage>(collectionView: collectionView) { collectionView, indexPath, animatedImage in
            let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: animatedImage)
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

    nonisolated private func loadAnimatedImages() async -> [AnimatedImage] {
        guard let actData = file.contents() else {
            return []
        }

        let sprData: Data?
        switch file {
        case .regularFile(let url):
            let sprPath = url.deletingPathExtension().path().appending(".spr")
            sprData = try? Data(contentsOf: URL(filePath: sprPath))
        case .grfEntry(let grf, let entry):
            let sprPath = entry.path.replacingExtension("spr")
            sprData = try? grf.contentsOfEntry(at: sprPath)
        default:
            sprData = nil
        }

        guard let sprData else {
            return []
        }

        guard let act = try? ACT(data: actData),
              let spr = try? SPR(data: sprData)
        else {
            return []
        }

        let sprites = spr.sprites.enumerated()
        let spritesByType = Dictionary(grouping: sprites, by: { $0.element.type })
        let imagesForSpritesByType = spritesByType.mapValues { sprites in
            sprites.map { sprite in
                spr.image(forSpriteAt: sprite.offset)?.image
            }
        }

        var animatedImages: [AnimatedImage] = []
        for index in 0..<act.actions.count {
            let animatedImage = act.animatedImage(forActionAt: index, imagesForSpritesByType: imagesForSpritesByType)
            animatedImages.append(animatedImage)
        }

        return animatedImages
    }

    nonisolated private func updateSnapshot(animatedImages: [AnimatedImage], animatingDifferences: Bool) async {
        var snapshot = NSDiffableDataSourceSnapshot<Section, AnimatedImage>()

        if animatedImages.count % 8 != 0 {
            let itemSize = animatedImages.reduce(CGSize(width: 80, height: 80)) { itemSize, image in
                CGSize(
                    width: max(itemSize.width, CGFloat(image.size.width)),
                    height: max(itemSize.height, CGFloat(image.size.height))
                )
            }
            let section = Section(index: 0, itemSize: itemSize)
            snapshot.appendSections([section])
            snapshot.appendItems(animatedImages, toSection: section)
        } else {
            let sectionCount = animatedImages.count / 8
            for sectionIndex in 0..<sectionCount {
                let animatedImagesInSection = Array(animatedImages[(sectionIndex * 8)..<((sectionIndex + 1) * 8)])
                let itemSize = animatedImagesInSection.reduce(CGSize(width: 80, height: 80)) { itemSize, image in
                    CGSize(
                        width: max(itemSize.width, CGFloat(image.size.width)),
                        height: max(itemSize.height, CGFloat(image.size.height))
                    )
                }
                let section = Section(index: sectionIndex, itemSize: itemSize)
                snapshot.appendSections([section])
                snapshot.appendItems(animatedImagesInSection, toSection: section)
            }
        }

        await diffableDataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
}

extension ACTPreviewViewController {
    struct Section: Hashable {
        var index: Int
        var itemSize: CGSize

        func hash(into hasher: inout Hasher) {
            index.hash(into: &hasher)
        }
    }
}

extension ACTPreviewViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        guard let indexPath = indexPaths.first,
              let cell = collectionView.cellForItem(at: indexPath),
              let animatedImage = diffableDataSource.itemIdentifier(for: indexPath)
        else {
            return nil
        }

        let index = indexPath.section * 8 + indexPath.item
        let activityItem = AnimatedImageActivityItem(animatedImage: animatedImage, filename: file.name, index: index)

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

extension ACTPreviewViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let section = diffableDataSource.sectionIdentifier(for: indexPath.section)
        return section?.itemSize ?? .zero
    }
}
