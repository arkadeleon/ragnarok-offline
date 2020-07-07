//
//  TextDocumentViewController.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/5/10.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import UIKit
import WebKit

class TextDocumentViewController: UIViewController {

    let document: AnyDocument<DocumentSource, String>

    private var webView: WKWebView!

    init(document: AnyDocument<DocumentSource, String>) {
        self.document = document
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = document.name

        view.backgroundColor = .systemBackground

        webView = WKWebView(frame: view.bounds)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(webView)

        document.loadAsynchronously { result in
            switch result {
            case .success(let string):
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
                            <code class="lua">\(string)</code>
                        </pre>
                    </body>
                </html>
                """
                let baseURL = Bundle.main.bundleURL.appendingPathComponent("Vendors/highlightjs")
                self.webView.loadHTMLString(htmlString, baseURL: baseURL)
            case .failure(let error):
                let alert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}
