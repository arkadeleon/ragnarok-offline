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

    let source: DocumentSource

    private var webView: WKWebView!

    init(source: DocumentSource) {
        self.source = source
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = source.name

        view.backgroundColor = .systemBackground

        webView = WKWebView(frame: view.bounds)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(webView)

        loadSource()
    }

    private func loadSource() {
        DispatchQueue.global().async {
            guard let data = try? self.source.data() else {
                return
            }

            var text: String? = nil
            let loader = DocumentLoader()
            switch self.source.fileType.lowercased() {
            case "txt":
                text = try? loader.load(TXTDocument.self, from: data).string
            case "lua":
                text = try? loader.load(LUADocument.self, from: data).string
            default:
                break
            }

            DispatchQueue.main.async {
                guard let text = text else {
                    return
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
                            <code>\(String(describing: text))</code>
                        </pre>
                    </body>
                </html>
                """
                let baseURL = Bundle.main.bundleURL.appendingPathComponent("Vendors/highlightjs")
                self.webView.loadHTMLString(htmlString, baseURL: baseURL)
            }
        }
    }
}
