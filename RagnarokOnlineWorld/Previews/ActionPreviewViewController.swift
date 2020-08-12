//
//  ActionPreviewViewController.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/8/13.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import UIKit

private let actionCellReuseIdentifier = "ActionCell"
private let frameCellReuseIdentifier = "FrameCell"

extension ActionPreviewViewController {

    struct Action {

        var frames: [CGImage?]
        var delay: Float

        init(action: ACTAction, spr: SPRDocument) {
            frames = action.animations.map { (animation) -> CGImage? in
                guard animation.layers.count > 0 else {
                    return nil
                }

                let frameIndex = Int(animation.layers[0].index)
                return spr.imageForFrame(at: frameIndex)
            }
            delay = action.delay
        }
    }
}

class ActionPreviewViewController: UIViewController {

    let previewItem: PreviewItem

    private var actions: [Action] = []
    private var selectedActionIndex: Int?
    private var selectedFrameIndex: Int?

    private var selectedAction: Action? {
        guard let selectedActionIndex = selectedActionIndex else {
            return nil
        }
        return actions[selectedActionIndex]
    }

    private var selectedFrame: CGImage? {
        guard let selectedAction = selectedAction,
              let selectedFrameIndex = selectedFrameIndex
        else {
            return nil
        }
        return selectedAction.frames[selectedFrameIndex]
    }

    private var actionsView: UICollectionView!
    private var framesView: UICollectionView!
    private var scrollView: UIScrollView!
    private var imageView: UIImageView!

    init(previewItem: PreviewItem) {
        self.previewItem = previewItem
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = previewItem.name

        view.backgroundColor = .systemBackground

        let actionsViewLayout = UICollectionViewFlowLayout()
        actionsViewLayout.itemSize = CGSize(width: 64, height: 64)
        actionsViewLayout.scrollDirection = .horizontal

        actionsView = UICollectionView(frame: .zero, collectionViewLayout: actionsViewLayout)
        actionsView.translatesAutoresizingMaskIntoConstraints = false
        actionsView.backgroundColor = .systemBackground
        actionsView.dataSource = self
        actionsView.delegate = self
        actionsView.showsVerticalScrollIndicator = false
        actionsView.showsHorizontalScrollIndicator = false
        actionsView.register(ActionCell.self, forCellWithReuseIdentifier: actionCellReuseIdentifier)
        view.addSubview(actionsView)

        actionsView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        actionsView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        actionsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        actionsView.heightAnchor.constraint(equalToConstant: 64).isActive = true

        let framesViewLayout = UICollectionViewFlowLayout()
        framesViewLayout.itemSize = CGSize(width: 96, height: 96)
        framesViewLayout.scrollDirection = .horizontal

        framesView = UICollectionView(frame: .zero, collectionViewLayout: framesViewLayout)
        framesView.translatesAutoresizingMaskIntoConstraints = false
        framesView.backgroundColor = .secondarySystemBackground
        framesView.dataSource = self
        framesView.delegate = self
        framesView.showsVerticalScrollIndicator = false
        framesView.showsHorizontalScrollIndicator = false
        framesView.register(ActionFrameCell.self, forCellWithReuseIdentifier: frameCellReuseIdentifier)
        view.addSubview(framesView)

        framesView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        framesView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        framesView.bottomAnchor.constraint(equalTo: actionsView.topAnchor).isActive = true
        framesView.heightAnchor.constraint(equalToConstant: 96).isActive = true

        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .tertiarySystemBackground
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        view.addSubview(scrollView)

        scrollView.frameLayoutGuide.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        scrollView.frameLayoutGuide.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        scrollView.frameLayoutGuide.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        scrollView.frameLayoutGuide.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -160).isActive = true

        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        scrollView.addSubview(imageView)

        loadPreviewItem()
    }

    private func loadPreviewItem() {
        DispatchQueue.global().async {
            guard case .entry(let url, let actName) = self.previewItem,
                  let actData = try? self.previewItem.data()
            else {
                return
            }

            let sprName = (actName as NSString).deletingPathExtension.appending(".spr")
            guard let sprData = try? ResourceManager.default.contentsOfEntry(withName: sprName, url: url) else {
                return
            }

            let loader = DocumentLoader()
            guard let actDocument = try? loader.load(ACTDocument.self, from: actData),
                  let sprDocument = try? loader.load(SPRDocument.self, from: sprData)
            else {
                return
            }

            var actions: [Action] = []
            for action in actDocument.actions {
                actions.append(Action(action: action, spr: sprDocument))
            }
            self.actions = actions
            self.selectedActionIndex = self.actions.count == 0 ? nil : 0

            DispatchQueue.main.async {
                self.actionsView.reloadData()

                guard self.actions.count > 0 else {
                    return
                }

                self.selectedActionIndex = 0
                self.actionsView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: .left)

                self.framesView.reloadData()

                guard let frames = self.selectedAction?.frames, frames.count > 0 else {
                    return
                }

                self.selectedFrameIndex = 0
                self.framesView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: .left)

                if let frame = self.selectedFrame {
                    self.imageView.image = UIImage(cgImage: frame)
                    self.imageView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)

                    self.scrollView.contentSize = CGSize(width: frame.width, height: frame.height)

                    self.updateZoomScale(image: frame)
                    self.centerScrollViewContents()
                }
            }
        }
    }

    private func updateZoomScale(image: CGImage) {
        let scrollViewFrame = scrollView.bounds

        let scaleWidth = scrollViewFrame.size.width / CGFloat(image.width)
        let scaleHeight = scrollViewFrame.size.height / CGFloat(image.height)
        let minScale = min(scaleWidth, scaleHeight)

        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = minScale * 3

        scrollView.zoomScale = minScale
    }

    private func centerScrollViewContents() {
        var horizontalInset: CGFloat = 0
        var verticalInset: CGFloat = 0

        if scrollView.contentSize.width < scrollView.bounds.width {
            horizontalInset = (scrollView.bounds.width - scrollView.contentSize.width) * 0.5
        }

        if scrollView.contentSize.height < scrollView.bounds.height {
            verticalInset = (scrollView.bounds.height - scrollView.contentSize.height) * 0.5
        }

        scrollView.contentInset = UIEdgeInsets(top: verticalInset, left: horizontalInset, bottom: verticalInset, right: horizontalInset)
    }
}

extension ActionPreviewViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView === actionsView {
            return actions.count
        } else if collectionView === framesView {
            return selectedAction?.frames.count ?? 0
        } else {
            fatalError()
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView === actionsView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: actionCellReuseIdentifier, for: indexPath) as! ActionCell
            cell.frameView.image = actions[indexPath.item].frames.first?.flatMap { UIImage(cgImage: $0) }
            return cell
        } else if collectionView === framesView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: frameCellReuseIdentifier, for: indexPath) as! ActionFrameCell
            cell.frameView.image = selectedAction?.frames[indexPath.item].flatMap { UIImage(cgImage: $0) }
            return cell
        } else {
            fatalError()
        }
    }
}

extension ActionPreviewViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView === actionsView {
            selectedActionIndex = indexPath.item
            framesView.reloadData()

            if let frames = self.selectedAction?.frames, frames.count > 0 {
                selectedFrameIndex = 0
                framesView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: .left)
                imageView.image = selectedFrame.flatMap { UIImage(cgImage: $0) }
            }
        } else if collectionView === framesView {
            selectedFrameIndex = indexPath.item
            imageView.image = selectedFrame.flatMap { UIImage(cgImage: $0) }
        } else {
            fatalError()
        }
    }
}

extension ActionPreviewViewController: UIScrollViewDelegate {

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerScrollViewContents()
    }
}
