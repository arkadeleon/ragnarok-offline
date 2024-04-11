//
//  FilePreviewPageViewController.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/11/16.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import UIKit
import ROFileSystem

class FilePreviewPageViewController: UIViewController {
    private(set) var file: File
    let files: [File]

    private var backBarButtonItem: UIBarButtonItem!
    private var shareBarButtonItem: UIBarButtonItem!
    private var pageViewController: UIPageViewController!

    init(file: File, files: [File]) {
        self.file = file
        self.files = files

        super.init(nibName: nil, bundle: nil)

        title = file.name
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        navigationItem.scrollEdgeAppearance = appearance

        let backAction = UIAction(image: UIImage(systemName: "chevron.left")) { _ in
            self.dismiss(animated: true)
        }
        backBarButtonItem = UIBarButtonItem(primaryAction: backAction)
        navigationItem.leftBarButtonItem = backBarButtonItem

        let shareAction = UIAction(image: UIImage(systemName: "square.and.arrow.up")) { _ in
            self.share()
        }
        shareBarButtonItem = UIBarButtonItem(primaryAction: shareAction)
        navigationItem.rightBarButtonItem = shareBarButtonItem

        addPageViewController()
    }

    private func addPageViewController() {
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        pageViewController.dataSource = self
        pageViewController.delegate = self

        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)

        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        pageViewController.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        pageViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        let previewViewController = FilePreviewViewController(file: file)
        pageViewController.setViewControllers([previewViewController], direction: .forward, animated: false)
    }

    private func share() {
        guard let activityItem = file.activityItem else {
            return
        }

        let activityViewController = UIActivityViewController(activityItems: [activityItem], applicationActivities: nil)
        activityViewController.modalPresentationStyle = .popover
        activityViewController.popoverPresentationController?.barButtonItem = shareBarButtonItem
        self.present(activityViewController, animated: true)
    }
}

extension FilePreviewPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = files.firstIndex(of: file) else {
            return nil
        }

        let previousIndex = index - 1
        guard previousIndex >= 0 else {
            return nil
        }

        let previousFile = files[previousIndex]
        let previewViewController = FilePreviewViewController(file: previousFile)
        return previewViewController
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = files.firstIndex(of: file) else {
            return nil
        }

        let nextIndex = index + 1
        guard nextIndex < files.count else {
            return nil
        }

        let nextFile = files[nextIndex]
        let previewViewController = FilePreviewViewController(file: nextFile)
        return previewViewController
    }
}

extension FilePreviewPageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let previewViewController = pageViewController.viewControllers?.first as? FilePreviewViewController, completed {
            file = previewViewController.file
            title = file.name
        }
    }
}
