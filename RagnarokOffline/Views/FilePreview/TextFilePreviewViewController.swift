//
//  TextFilePreviewViewController.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/12/19.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import Lua
import UIKit
import WebKit

class TextFilePreviewViewController: UIViewController {
    let file: File

    private var webView: WKWebView!

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

        webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)

        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        Task {
            guard let text = await loadText() else {
                return
            }

            let htmlString = """
                <!doctype html>
                <meta charset="utf-8">
                <meta name="viewport" content="height=device-height, initial-scale=1.0, user-scalable=no, minimum-scale=1.0, maximum-scale=1.0">
                <style>
                    code {
                        word-wrap: break-word;
                        white-space: -moz-pre-wrap;
                        white-space: pre-wrap;
                    }
                </style>
                <pre><code>\(text)</code></pre>
                """
            webView.loadHTMLString(htmlString, baseURL: nil)
        }
    }

    nonisolated private func loadText() async -> String? {
        guard let type = file.type, var data = file.contents() else {
            return nil
        }

        switch type {
        case .lub:
            let decompiler = LuaDecompiler()
            if let decompiledData = decompiler.decompileData(data) {
                data = decompiledData
            }
        default:
            break
        }

        var convertedString: NSString? = nil
        NSString.stringEncoding(for: data, convertedString: &convertedString, usedLossyConversion: nil)

        return convertedString as String?
    }
}
