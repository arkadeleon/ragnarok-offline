//
//  ActionAnimationCell.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/8/7.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import UIKit

class ActionAnimationCell: UICollectionViewCell {

    let frameView: UIImageView

    override init(frame: CGRect) {
        frameView = UIImageView()
        frameView.translatesAutoresizingMaskIntoConstraints = false
        frameView.contentMode = .scaleAspectFit

        super.init(frame: frame)

        contentView.addSubview(frameView)
        frameView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        frameView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        frameView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        frameView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
