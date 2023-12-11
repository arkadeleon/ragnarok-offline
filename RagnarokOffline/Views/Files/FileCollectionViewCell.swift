//
//  FileCollectionViewCell.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/11/16.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import UIKit

class FileCollectionViewCell: UICollectionViewCell {
    var thumbnailView: UIImageView!
    var nameLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)

        thumbnailView = UIImageView()
        thumbnailView.translatesAutoresizingMaskIntoConstraints = false
        thumbnailView.contentMode = .scaleAspectFit
        thumbnailView.tintColor = .label
        contentView.addSubview(thumbnailView)

        thumbnailView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        thumbnailView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        thumbnailView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        thumbnailView.heightAnchor.constraint(equalToConstant: 40).isActive = true

        nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        nameLabel.textColor = .label
        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 2
        contentView.addSubview(nameLabel)

        nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: thumbnailView.bottomAnchor, constant: 8).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with file: File) {
        thumbnailView.image = nil
        FileThumbnailCache.shared.generateThumbnail(for: file) { [weak self] thumbnail in
            DispatchQueue.main.async {
                switch thumbnail {
                case .icon(let name):
                    if let type = file.type, type.conforms(to: .directory) {
                        self?.thumbnailView.image = UIImage(systemName: name)?.withRenderingMode(.alwaysOriginal)
                    } else {
                        self?.thumbnailView.image = UIImage(systemName: name)?.withRenderingMode(.alwaysTemplate)
                    }
                case .thumbnail(let image):
                    self?.thumbnailView.image = image
                }
            }
        }

        nameLabel.text = file.name
    }
}
