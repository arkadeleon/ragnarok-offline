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

    private func presentFileInfoViewController(file: File) {
        let fileInfoViewController = FileInfoViewController(file: file)
        let navigationController = UINavigationController(rootViewController: fileInfoViewController)
        present(navigationController, animated: true)
    }

    private func presentFilePreviewViewController(file: File) {
        let files = diffableDataSource.snapshot().itemIdentifiers.filter { file in
            guard let type = file.type else {
                return false
            }
            if type.conforms(to: .directory) || type.conforms(to: .archive) {
                return false
            } else {
                return true
            }
        }

        let pageViewController = FilePreviewPageViewController(file: file, files: files)
        let navigationController = UINavigationController(rootViewController: pageViewController)
        navigationController.modalTransitionStyle = .coverVertical
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }
}

extension FilesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let file = diffableDataSource.itemIdentifier(for: indexPath), let type = file.type else {
            return
        }

        if type.conforms(to: .directory) || type.conforms(to: .archive) {
            let filesViewController = FilesViewController(file: file)
            navigationController?.pushViewController(filesViewController, animated: true)
        } else {
            presentFilePreviewViewController(file: file)
        }
    }

    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        let files = indexPaths.compactMap({ diffableDataSource.itemIdentifier(for: $0) })

        var actions: [UIAction] = []

        if let file = files.first, file.hasInfo {
            let fileInfoAction = UIAction(title: "File Info", image: UIImage(systemName: "info.circle")) { _ in
                self.presentFileInfoViewController(file: file)
            }
            actions.append(fileInfoAction)
        }

        if let file = files.first, let type = file.type {
            if !type.conforms(to: .directory) && !type.conforms(to: .archive) {
                let previewAction = UIAction(title: "Preview", image: UIImage(systemName: "eye")) { _ in
                    self.presentFilePreviewViewController(file: file)
                }
                actions.append(previewAction)
            }
        }

        if let file = files.first, let type = file.type, !type.conforms(to: .directory), !type.conforms(to: .archive) {
            let copyAction = UIAction(title: "Copy", image: UIImage(systemName: "doc.on.doc")) { _ in
                FilePasteboard.shared.copy(file)
            }
            actions.append(copyAction)
        }

        if let type = file.type, type.conforms(to: .directory), FilePasteboard.shared.hasFile {
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

        let shareAction = UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up")) { _ in
            let activityItems = files.map({ $0.activityItem }).compactMap({ $0 })
            let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
            self.present(activityViewController, animated: true)
        }
        actions.append(shareAction)

        if let file = files.first, let type = file.type, case .url(let url) = file, !type.conforms(to: .directory) {
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
