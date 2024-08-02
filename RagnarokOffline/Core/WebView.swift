//
//  WebView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2023/4/7.
//

import SwiftUI
import WebKit

#if os(macOS)

struct WebView: NSViewRepresentable {
    let htmlString: String
    let baseURL: URL?

    func makeNSView(context: Context) -> WKWebView {
        WKWebView()
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        webView.loadHTMLString(htmlString, baseURL: baseURL)
    }
}

#else

struct WebView: UIViewRepresentable {
    let htmlString: String
    let baseURL: URL?

    func makeUIView(context: Context) -> WKWebView {
        WKWebView()
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.loadHTMLString(htmlString, baseURL: baseURL)
    }
}

#endif
