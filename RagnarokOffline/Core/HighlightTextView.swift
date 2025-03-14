//
//  HighlightTextView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/3/14.
//

import Highlight
import SwiftUI
import WebKit

#if os(macOS)

struct HighlightTextView: NSViewRepresentable {
    let text: String

    func makeNSView(context: Context) -> WKWebView {
        WKWebView()
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        webView.highlightText(text)
    }
}

#else

struct HighlightTextView: UIViewRepresentable {
    let text: String

    func makeUIView(context: Context) -> WKWebView {
        WKWebView()
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.highlightText(text)
    }
}

#endif
