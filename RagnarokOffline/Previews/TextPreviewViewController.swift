//
//  TextPreviewViewController.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/5/10.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import UIKit
import Highlighter

class TextPreviewViewController: UIViewController {

    let previewItem: PreviewItem

    private var textView: UITextView!

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

        textView = UITextView(frame: view.bounds)
        textView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(textView)

        loadPreviewItem()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if previousTraitCollection == nil || previousTraitCollection!.userInterfaceStyle != traitCollection.userInterfaceStyle {
            loadPreviewItem()
        }
    }

    private func loadPreviewItem() {
        DispatchQueue.global().async {
            guard var data = try? self.previewItem.data() else {
                return
            }

            switch self.previewItem.fileType {
            case .lub:
                let decompiler = LuaDecompiler()
                data = decompiler.decompileData(data)
            default:
                break
            }

            DispatchQueue.main.async {
                let style: Highlighter.Style
                switch self.traitCollection.userInterfaceStyle {
                case .unspecified, .light:
                    style = .atomOneLight
                case .dark:
                    style = .atomOneDark
                @unknown default:
                    style = .default
                }

                guard let highlighter = Highlighter(style: style),
                      let text = String(data: data, encoding: .ascii)
                else {
                    return
                }

                self.textView.attributedText = highlighter.highlight(text)
            }
        }
    }
}
