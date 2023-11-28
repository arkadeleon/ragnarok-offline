//
//  FilesViewController.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/11/16.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import UIKit

class FilesViewController: UIViewController {
    let file: File

    private var collectionView: UICollectionView!
    private var activityIndicatorView: UIActivityIndicatorView!

    private var diffableDataSource: UICollectionViewDiffableDataSource<String, File>!

    init(file: File) {
        self.file = file

        super.init(nibName: nil, bundle: nil)

        title = file.name
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        addActionCollectionView()
        addActivityIndicatorView()

        activityIndicatorView.startAnimating()

        Task(priority: .userInitiated) { [weak self] in
            if let files = await self?.loadFiles() {
                await self?.updateSnapshot(files: files, animatingDifferences: false)
            }
            self?.activityIndicatorView.stopAnimating()
        }
    }

    private func addActionCollectionView() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 32
        flowLayout.minimumInteritemSpacing = 16
        flowLayout.itemSize = CGSize(width: 80, height: 88)
        flowLayout.sectionInset = UIEdgeInsets(top: 32, left: 32, bottom: 32, right: 32)

        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.delegate = self

        let cellRegistration = UICollectionView.CellRegistration<FileCollectionViewCell, File> { cell, indexPath, file in

        }

        diffableDataSource = UICollectionViewDiffableDataSource<String, File>(collectionView: collectionView) { collectionView, indexPath, file in
            let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: file)
            cell.configure(with: file)
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

    nonisolated private func loadFiles() async -> [File] {
        file.files().sorted()
    }

    nonisolated private func updateSnapshot(files: [File], animatingDifferences: Bool) async {
        var snapshot = NSDiffableDataSourceSnapshot<String, File>()

        snapshot.appendSections(["All"])
        snapshot.appendItems(files, toSection: "All")

        await diffableDataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
}

extension FilesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let file = diffableDataSource.itemIdentifier(for: indexPath) else {
            return
        }

        if file.isDirectory || file.isArchive {
            let filesViewController = FilesViewController(file: file)
            navigationController?.pushViewController(filesViewController, animated: true)
        } else if let fileType = file.contentType, fileType != .xxx {
            let files = diffableDataSource.snapshot().itemIdentifiers
                .filter { file in
                    if let fileType = file.contentType, fileType != .xxx {
                        true
                    } else {
                        false
                    }
                }

            let pageViewController = FilePreviewPageViewController(file: file, files: files)
            let navigationController = UINavigationController(rootViewController: pageViewController)
            navigationController.modalTransitionStyle = .coverVertical
            navigationController.modalPresentationStyle = .fullScreen
            present(navigationController, animated: true)
        }
    }

    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        let files = indexPaths.compactMap({ diffableDataSource.itemIdentifier(for: $0) })

        var actions: [UIAction] = []

        if let file = files.first, file.hasInfo {
            let fileInfoAction = UIAction(title: "File Info", image: UIImage(systemName: "info.circle")) { _ in
                let fileInfoViewController = FileInfoViewController(file: file)
                let navigationController = UINavigationController(rootViewController: fileInfoViewController)
                self.present(navigationController, animated: true)
            }
            actions.append(fileInfoAction)
        }

        if let file = files.first, !file.isDirectory && !file.isArchive {
            let copyAction = UIAction(title: "Copy", image: UIImage(systemName: "doc.on.doc")) { _ in
                FilePasteboard.shared.copy(file)
            }
            actions.append(copyAction)
        }

        if file.isDirectory && FilePasteboard.shared.hasFile {
            let pasteAction = UIAction(title: "Paste", image: UIImage(systemName: "doc.on.clipboard")) { _ in
                if let file = self.file.pasteFromPasteboard(FilePasteboard.shared) {
                    Task {
                        var files = self.diffableDataSource.snapshot().itemIdentifiers
                        files.append(file)
                        files.sort()
                        await self.updateSnapshot(files: files, animatingDifferences: true)
                    }
                }
            }
            actions.append(pasteAction)
        }

        if let file = files.first, case .url(let url) = file, !file.isDirectory {
            let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                do {
                    try FileManager.default.removeItem(at: url)
                    Task {
                        var files = self.diffableDataSource.snapshot().itemIdentifiers
                        files.removeAll(where: { $0 == file })
                        await self.updateSnapshot(files: files, animatingDifferences: true)
                    }
                } catch {
                }
            }
            actions.append(deleteAction)
        }

        let configuration = UIContextMenuConfiguration(actionProvider: { _ in
            UIMenu(children: actions)
        })
        return configuration
    }
}
