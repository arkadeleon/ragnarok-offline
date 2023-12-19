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
    struct ActionSection: Hashable {
        var index: Int
        var actions: [Action]

        func hash(into hasher: inout Hasher) {
            index.hash(into: &hasher)
        }
    }

    struct Action: Hashable {
        var index: Int
        var size: CGSize
        var animatedImage: AnimatedImage

        func hash(into hasher: inout Hasher) {
            index.hash(into: &hasher)
        }
    }

    let file: File

    private var collectionView: UICollectionView!
    private var activityIndicatorView: UIActivityIndicatorView!

    private var diffableDataSource: UICollectionViewDiffableDataSource<ActionSection, Action>!

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
            let actionSections = await loadActionSections()
            await updateSnapshot(with: actionSections, animatingDifferences: false)
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

        let cellRegistration = UICollectionView.CellRegistration<ImageCollectionViewCell, Action> { cell, indexPath, action in
            let images = action.animatedImage.images.map(UIImage.init)
            let duration = action.animatedImage.delay * CGFloat(action.animatedImage.images.count)
            cell.imageView.image = UIImage.animatedImage(with: images, duration: duration)
        }

        diffableDataSource = UICollectionViewDiffableDataSource<ActionSection, Action>(collectionView: collectionView) { collectionView, indexPath, action in
            let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: action)
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

    nonisolated private func loadActionSections() async -> [ActionSection] {
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

        if animatedImages.count % 8 != 0 {
            let size = animatedImages.reduce(CGSize(width: 80, height: 80)) { size, animatedImage in
                CGSize(
                    width: max(size.width, CGFloat(animatedImage.size.width)),
                    height: max(size.height, CGFloat(animatedImage.size.height))
                )
            }
            let actions = animatedImages.enumerated().map { (index, animatedImage) in
                Action(index: index, size: size, animatedImage: animatedImage)
            }
            let actionSection = ActionSection(index: 0, actions: actions)
            return [actionSection]
        } else {
            let sectionCount = animatedImages.count / 8
            let actionSections = (0..<sectionCount).map { sectionIndex in
                let startIndex = sectionIndex * 8
                let endIndex = (sectionIndex + 1) * 8
                let animatedImages = Array(animatedImages[startIndex..<endIndex])
                let size = animatedImages.reduce(CGSize(width: 80, height: 80)) { size, animatedImage in
                    CGSize(
                        width: max(size.width, CGFloat(animatedImage.size.width)),
                        height: max(size.height, CGFloat(animatedImage.size.height))
                    )
                }
                let actions = animatedImages.enumerated().map { (index, animatedImage) in
                    Action(index: startIndex + index, size: size, animatedImage: animatedImage)
                }
                let actionSection = ActionSection(index: sectionIndex, actions: actions)
                return actionSection
            }
            return actionSections
        }
    }

    nonisolated private func updateSnapshot(with actionSections: [ActionSection], animatingDifferences: Bool) async {
        var snapshot = NSDiffableDataSourceSnapshot<ActionSection, Action>()

        for actionSection in actionSections {
            snapshot.appendSections([actionSection])
            snapshot.appendItems(actionSection.actions, toSection: actionSection)
        }

        await diffableDataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
}

extension ACTPreviewViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        guard let indexPath = indexPaths.first,
              let cell = collectionView.cellForItem(at: indexPath),
              let action = diffableDataSource.itemIdentifier(for: indexPath)
        else {
            return nil
        }

        let activityItem = AnimatedImageActivityItem(animatedImage: action.animatedImage, filename: file.name, index: action.index)

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
        let action = diffableDataSource.itemIdentifier(for: indexPath)
        return action?.size ?? .zero
    }
}
