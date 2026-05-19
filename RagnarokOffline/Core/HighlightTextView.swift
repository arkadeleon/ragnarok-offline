//
//  HighlightTextView.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2025/3/14.
//

import Highlight
import SwiftUI
import WebKit

#if canImport(UIKit)

struct HighlightTextView: UIViewRepresentable {
    let text: String

    @Environment(\.colorScheme) private var colorScheme

    private var style: String {
        switch colorScheme {
        case .light:
            "github"
        case .dark:
            "github-dark"
        @unknown default:
            "default"
        }
    }

    func makeUIView(context: Context) -> WKWebView {
        WKWebView()
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.highlightCode(text, style: style)
    }
}

#elseif canImport(AppKit)

struct HighlightTextView: NSViewRepresentable {
    let text: String

    @Environment(\.colorScheme) private var colorScheme

    private var style: String {
        switch colorScheme {
        case .light:
            "github"
        case .dark:
            "github-dark"
        @unknown default:
            "default"
        }
    }

    func makeNSView(context: Context) -> WKWebView {
        WKWebView()
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        webView.highlightCode(text, style: style)
    }
}

#endif
