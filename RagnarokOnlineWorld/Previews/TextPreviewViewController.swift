//
//  TextPreviewViewController.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/5/10.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import UIKit
import WebKit

class TextPreviewViewController: UIViewController {

    let previewItem: PreviewItem

    private var webView: WKWebView!

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

        webView = WKWebView(frame: view.bounds)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(webView)

        loadPreviewItem()
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
                guard var text = String(data: data, encoding: .ascii) else {
                    return
                }

                if self.previewItem.fileType == .xml {
                    text = text.replacingOccurrences(of: "<", with: "&lt;")
                    text = text.replacingOccurrences(of: ">", with: "&gt;")
                }

                let htmlString = """
                <html>
                    <head>
                        <meta name="viewport" content="width=device-width; initial-scale=1.0">
                        <link rel="stylesheet" href="styles/default.css">
                        <style>
                            pre, code {
                                white-space: pre-wrap;
                                overflow-x: hidden;
                            }
                            .hljs {
                                overflow-x: hidden;
                            }
                        </style>
                        <script src="highlight.pack.js"></script>
                        <script>
                            hljs.initHighlightingOnLoad();
                        </script>
                    </head>
                    <body>
                        <pre>
                            <code>\(text)</code>
                        </pre>
                    </body>
                </html>
                """
                let baseURL = Bundle.main.bundleURL.appendingPathComponent("Highlight.js")
                self.webView.loadHTMLString(htmlString, baseURL: baseURL)
            }
        }
    }
}
