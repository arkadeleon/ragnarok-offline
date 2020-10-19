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

        title = previewItem.title

        view.backgroundColor = .systemBackground

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
        framesView.register(SpriteFrameCell.self, forCellWithReuseIdentifier: frameCellReuseIdentifier)
        view.addSubview(framesView)

        framesView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        framesView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        framesView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        framesView.heightAnchor.constraint(equalToConstant: 96).isActive = true

        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .tertiarySystemBackground
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        view.addSubview(scrollView)

        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        scrollView.addSubview(imageView)

        scrollView.frameLayoutGuide.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        scrollView.frameLayoutGuide.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        scrollView.frameLayoutGuide.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        scrollView.frameLayoutGuide.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -96).isActive = true

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

                guard self.frames.count > 0, let frame = frames[0] else {
                    return
                }

                let indexPath = IndexPath(item: 0, section: 0)
                self.framesView.selectItem(at: indexPath, animated: false, scrollPosition: .left)

                self.imageView.image = UIImage(cgImage: frame)
                self.imageView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)

                self.scrollView.contentSize = CGSize(width: frame.width, height: frame.height)

                self.updateZoomScale(image: frame)
                self.centerScrollViewContents()
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

extension SpritePreviewViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        imageView.image = frames[indexPath.item].flatMap { UIImage(cgImage: $0) }
    }
}

extension SpritePreviewViewController: UIScrollViewDelegate {

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerScrollViewContents()
    }
}
