//
//  TextPreviewViewController.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/5/10.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import UIKit
import WebKit
import Highlight

class TextPreviewViewController: UIViewController {

    let previewItem: PreviewItem

    private var webView: WKWebView!

    init(previewItem: PreviewItem) {
        self.previewItem = previewItem
        super.init(nibName: nil, bundle: nil)
        title = previewItem.title
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        webView = WKWebView(frame: view.bounds)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(webView)

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
                let style: HighlightStyle
                switch self.traitCollection.userInterfaceStyle {
                case .unspecified, .light:
                    style = .atomOneLight
                case .dark:
                    style = .atomOneDark
                @unknown default:
                    style = .default
                }

                guard let text = String(data: data, encoding: .ascii)
                else {
                    return
                }

                self.webView.loadCode(text, style: style)
            }
        }
    }
}
