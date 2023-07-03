//
//  SelfSizingHeightWebView.swift
//  Blue Cross
//
//  Created by Zeng Guojie on 4/7/2019.
//  Copyright © 2019 Innopage Limited. All rights reserved.
//

import UIKit
import WebKit
import SwiftUI

class UISelfSizingHeightWebView: WKWebView, WKNavigationDelegate {
    var didGetHeightCallback: ((CGFloat) -> Void)?
    var didAttemptToOpenUrlCallback: ((URL) -> Void)?
    var font: UIFont?
    var textColor: UIColor?
    var htmlHeightCache: [String: CGFloat] = ["": 0]
    var html: String?
    var isDisableSelfSizing: Bool = false
    var htmlContentHeightExtra: CGFloat = 80
    fileprivate var _url: URL?
    
    private var heightConstraint: NSLayoutConstraint!
    private var needsCalculateHeight: Bool = true // TODO: expect same width for every view
    
    init() {
        let userContentController = WKUserContentController()
        let source = """
            var meta = document.createElement('meta');
            meta.name = 'viewport';
            meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
            var head = document.getElementsByTagName('head')[0];
            head.appendChild(meta);
        """
        let script = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        userContentController.addUserScript(script)
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userContentController
        
        super.init(frame: .zero, configuration: configuration)
        navigationDelegate = self
        
        if isDisableSelfSizing {
            scrollView.isScrollEnabled = true
        } else {
            heightConstraint = heightAnchor.constraint(equalToConstant: 0)
            heightConstraint.isActive = true
            scrollView.isScrollEnabled = false

            if #available(iOS 11.0, *) {
                scrollView.contentInsetAdjustmentBehavior = .never
            } else {
            }
        }
        self.layoutMargins = .zero
        self.preservesSuperviewLayoutMargins = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func load(url: URL) {
        if url != _url {
            _url = url
            let request = URLRequest(url: url)
            
            if !isDisableSelfSizing {
                if let height = self.htmlHeightCache[url.absoluteString] {
                    self.heightConstraint.constant = height
                    self.needsCalculateHeight = false
                }
                else {
                    heightConstraint.constant = 0
                    self.needsCalculateHeight = true
                }
            }

            load(request)
        }
    }
    
    func load(html: String) {
        if html != self.html {
            self.html = html
            
            let uifont = TP1App_UIFontFile_NotoSans_Regular(size: 16, style: .body)
            
            if !isDisableSelfSizing {
                if let height = self.htmlHeightCache[html] {
                    self.heightConstraint.constant = height
                    self.needsCalculateHeight = false
                }
                else {
                    heightConstraint.constant = 0
                    self.needsCalculateHeight = true
                }
            }
            
            let fontCSS: String
            if let font = font {
                fontCSS = #"""
                font-family: '\#(font.fontName)', sans-serif;
                font-size:\#(font.pointSize)px;
                """#
            }
            else {
                fontCSS = ""
            }
            
            let colorCSS: String
            if let textColor = textColor {
                colorCSS = #"""
                color: \#(textColor.hexString);
                """#
            }
            else {
                colorCSS = ""
            }
            
            let linkColorCSS: String
            if let tintColor = self.tintColor {
                linkColorCSS = #"""
                a {
                color: \#(tintColor.hexString);
                }
                """#
            }
            else {
                linkColorCSS = ""
            }
            
//            \#(fontCSS)
            
            
            let newHtml = #"""
            <style>
            body {
            margin:0;
            \#(colorCSS)
            }
            \#(linkColorCSS)
            @font-face {
                font-family: 'NotoSans';
                src: url('NotoSans-Regular.ttf') format('truetype');
            }
            @font-face {
                font-family: 'NotoSansLight';
                src: url('NotoSans-Light.ttf') format('truetype');
            }
            body {
                font-size: \#(uifont.pointSize)px;
                font-family: 'NotoSans';
                line-height: \#(uifont.pointSize * 1.361875)px;
            }
            </style>
            \#(html)
            """#
//            \#(Bundle.main.bundleURL)
            let bundlePath = Bundle.main.bundlePath
            let bundleUrl = URL.init(fileURLWithPath: bundlePath)
            loadHTMLString(newHtml, baseURL: bundleUrl)
//            loadHTMLString(newHtml, baseURL: nil)
            print(newHtml)
        }
    }
    
    // MARK: - WKNavigationDelegate
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard !isDisableSelfSizing else { return }
        guard needsCalculateHeight else { return }
        let calculateHeigthHandler = {
            webView.evaluateJavaScript("document.readyState", completionHandler: { (complete, error) in
                if complete != nil {
                    webView.evaluateJavaScript("document.documentElement.scrollHeight", completionHandler: { (height, error) in
                        if let height = height as? CGFloat {
                            let hgh = height + self.htmlContentHeightExtra
                            self.heightConstraint.constant = hgh
                            if let html = self.html, self.htmlHeightCache[html] == nil {
                                self.htmlHeightCache[html] = hgh
                            }
                            else if let urlString = self._url?.absoluteString, self.htmlHeightCache[urlString] == nil {
                                self.htmlHeightCache[urlString] = hgh
                            }
                            self.didGetHeightCallback?(hgh)
                        }
                    })
                }
            })
        }
        if #available(iOS 12.0, *) {
            calculateHeigthHandler()
        }
        else {
            superview?.layoutIfNeeded()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.superview?.layoutIfNeeded()
                calculateHeigthHandler()
            }
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url,
            url.absoluteString != "about:blank",
            url != _url,
            let scheme = url.scheme
        {
            if scheme == "file"
            {
                decisionHandler(.allow)
            }
            else
            {
                decisionHandler(.cancel)
                if scheme.contains("http") {
                    if let didAttemptToOpenUrlCallback = didAttemptToOpenUrlCallback {
                        didAttemptToOpenUrlCallback(url)
                    }
                    else {
                        UIApplication.shared.open(url)
                    }
                }
                else {
                    UIApplication.shared.open(url)
                }
            }
        }
        else {
            decisionHandler(.allow)
        }
    }
}


final class UINoCacheSelfSizingHeightWebView: UISelfSizingHeightWebView {
    override func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if html == nil && navigationAction.request.url == _url {
            var request = navigationAction.request
            if request.cachePolicy != URLRequest.CachePolicy.reloadIgnoringLocalCacheData {
                request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalCacheData
                decisionHandler(.cancel)
                webView.load(request)
                return
            }
        }
        
        super.webView(webView, decidePolicyFor: navigationAction, decisionHandler: decisionHandler)
    }
}








struct SelfSizingHeightWebView: UIViewRepresentable {

    var customWebView: UINoCacheSelfSizingHeightWebView?
    var url: URL?
    var html: String?
    var isDisableSelfSizing: Bool = false
    var htmlContentHeightExtra: CGFloat = 80
    var loadingCallback: ((_ newVal: Double?, _ oldVal: Double?) -> Void)?
    var didGetHeightCallback: ((CGFloat) -> Void)?
    var didAttemptToOpenUrlCallback: ((URL) -> Void)?
    @State private var observation: NSKeyValueObservation?

    func makeUIView(context: Context) -> UINoCacheSelfSizingHeightWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        var wv : UINoCacheSelfSizingHeightWebView? = nil
        if let wk = customWebView {
            wv = wk
        } else {
            let webView = UINoCacheSelfSizingHeightWebView()
            wv = webView
        }
        let webView = wv!

        webView.isDisableSelfSizing = isDisableSelfSizing
        webView.htmlContentHeightExtra = htmlContentHeightExtra
//        webView.textColor = UIColor.dynamicColor(light: UIColor(red: 0.22, green: 0.22, blue: 0.22, alpha: 1.0), dark: UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0))
        webView.textColor = TP1ViewElementStyles.shared.activeColorTheme.color_content_notes.uiColor()
        webView.tintColor = UIColor(hex: "#FF5D02")
        webView.font = UIFont(name: "SourceSansPro-Regular", size: 14)
        webView.didAttemptToOpenUrlCallback = didAttemptToOpenUrlCallback
        webView.didGetHeightCallback = didGetHeightCallback
        webView.backgroundColor = UITraitCollection.current.userInterfaceStyle == .dark ? PaletteHelper.uicolor_hex_bgBlack : PaletteHelper.uicolor_hex_bgWhite
        webView.backgroundColor = UIColor.clear
        webView.isOpaque = false

        
        DispatchQueue.main.async {
            observation = webView.observe(\UINoCacheSelfSizingHeightWebView.estimatedProgress, options: .new) { _, change in
                print("Loaded: \(change)")
                if let lc = loadingCallback { lc(change.newValue, change.oldValue) }
            }
        }

        return webView
    }

    func updateUIView(_ webView: UINoCacheSelfSizingHeightWebView, context: Context) {
        if let url = url {
            webView.load(url: url)
        } else if let html = html {
            webView.load(html: html)
        }
    }
}



