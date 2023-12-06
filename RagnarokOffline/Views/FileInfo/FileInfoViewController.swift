//
//  FileInfoViewController.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/11/27.
//  Copyright © 2023 Leon & Vane. All rights reserved.
//

import WebKit
import UIKit

class FileInfoViewController: UIViewController {
    let file: File

    private var webView: WKWebView!

    init(file: File) {
        self.file = file
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "File Info"

        webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)

        webView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        webView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        Task {
            await loadFileInfo()
        }
    }

    nonisolated private func loadFileInfo() async {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]

        guard let fileInfo = file.info,
              let data = try? encoder.encode(fileInfo),
              let string = String(data: data, encoding: .utf8)
        else {
            return
        }

        let htmlString = """
        <!doctype html>

        <meta charset="utf-8">
        <meta name="viewport" content="height=device-height, initial-scale=1.0, user-scalable=no, minimum-scale=1.0, maximum-scale=1.0">

        <link href="jsoneditor.min.css" rel="stylesheet" type="text/css">
        <script src="jsoneditor.min.js"></script>

        <div id="jsoneditor"></div>

        <script>
            // create the editor
            const container = document.getElementById("jsoneditor")
            const options = {}
            const editor = new JSONEditor(container, options)

            editor.setMode('view')
            editor.setName('\(file.name)')

            // set json
            const json = \(string)
            editor.set(json)
        </script>
        """
        let baseURL = Bundle.main.resourceURL?.appendingPathComponent("jsoneditor")
        await webView.loadHTMLString(htmlString, baseURL: baseURL)
    }
}
