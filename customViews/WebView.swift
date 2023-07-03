//
//  WebView.swift
//  hkstp oneapp testing
//
//  Created by Leung Yu Wing on 13/1/2022.
//

import Foundation
import SwiftUI
import WebKit



class WebViewNavigationDelegateWithOverrideUrl : NSObject, WKNavigationDelegate
{
    var onCallbackSpecialTag : ((String?) -> Void)?
    var didAttemptToOpenUrlCallback: ((URL) -> Void)?

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("URL: \(webView.url?.absoluteString ?? "")")
    }

    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("didStartProvisionalNavigation URL: \(webView.url?.absoluteString ?? "")")
        
        
        // VAN HACK - FBS - facilities_scan_pay.php detection
        if let onCallbackSpecialTag = onCallbackSpecialTag
        {
            if let urlString = webView.url?.absoluteString
            {
                if urlString.contains("/facilities_scan_pay.php")
                {
                    onCallbackSpecialTag("fps_qr_code")
                }
                else
                {
                    onCallbackSpecialTag(nil)
                }
            }
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("didFinish URL: \(webView.url?.absoluteString ?? "")")
    }
    
    
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url,
            url.absoluteString != "about:blank",
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
                    } else {
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



class WebViewScrollViewDelegate: NSObject, UIScrollViewDelegate {
    var onScroll: ((_ scrollView: UIScrollView) -> Void)?
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let onScroll = onScroll {
            onScroll(scrollView)
        }
    }
}

struct WebView: UIViewRepresentable {

    var customWebView: WKWebView?
    var url: URL?
    var html: String?
    var userScalable: Bool = false
    var loadingCallback: ((_ newVal: Double?, _ oldVal: Double?) -> Void)?
    var onCallbackSpecialTag : ((String?) -> Void)?
    var onCallbackWebView : ((WKWebView) -> Void)?
    var onScroll: ((_ scrollView: UIScrollView) -> Void)?
    var didAttemptToOpenUrlCallback: ((URL) -> Void)?
    @State private var observation: NSKeyValueObservation?
    
    let navigationDelegateWithOverrideUrl : WebViewNavigationDelegateWithOverrideUrl = WebViewNavigationDelegateWithOverrideUrl()
    let uiDelegate : WebViewUIDelegate = WebViewUIDelegate()
    let scrollViewDelegate: WebViewScrollViewDelegate = WebViewScrollViewDelegate()

    func makeUIView(context: Context) -> WKWebView {
        var wv : WKWebView? = nil
        
        let userContentController = WKUserContentController()
        let source = """
            var meta = document.createElement('meta');
            meta.name = 'viewport';
            meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=\(userScalable ? "7.0":"1.0"), user-scalable=\(userScalable ? "yes":"no")';
            var head = document.getElementsByTagName('head')[0];
            head.appendChild(meta);
        """
        let script = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        userContentController.addUserScript(script)
        
        if let wk = customWebView {
            wk.configuration.allowsInlineMediaPlayback = true
            wk.configuration.userContentController = userContentController
            wv = wk
        } else {
            let configuration = WKWebViewConfiguration()
            configuration.allowsInlineMediaPlayback = true
            configuration.userContentController = userContentController
            let webView = FullScreenWKWebView(frame: .zero, configuration: configuration)
            wv = webView
        }
        let webView = wv!


        webView.uiDelegate = uiDelegate

        webView.scrollView.delegate = scrollViewDelegate
        webView.navigationDelegate = navigationDelegateWithOverrideUrl
        scrollViewDelegate.onScroll = onScroll

        navigationDelegateWithOverrideUrl.didAttemptToOpenUrlCallback = didAttemptToOpenUrlCallback
        navigationDelegateWithOverrideUrl.onCallbackSpecialTag = { tag in
            if let onCallbackSpecialTag = onCallbackSpecialTag {
                onCallbackSpecialTag(tag)
            }
        }

        DispatchQueue.main.async {
            observation = webView.observe(\WKWebView.estimatedProgress, options: .new) { _, change in
                print("Loaded: \(change)")
                print("loading url: \(webView.url?.absoluteString ?? "")")
                if let lc = loadingCallback { lc(change.newValue, change.oldValue) }
            }
        }

        if let url = url {
            let request = URLRequest(url: url)
            webView.load(request)
        } else if let html = html {
            
            let uifont = TP1App_UIFontFile_NotoSans_Regular(size: 16, style: .body)
            
            let textColor = TP1ViewElementStyles.shared.activeColorTheme.color_content_notes.uiColor()
            let tintColor = UIColor(hex: "#FF5D02")

            let colorCSS: String
            colorCSS = #"""
            color: \#(textColor.hexString);
            """#

            let linkColorCSS: String
            linkColorCSS = #"""
            a {
            color: \#(tintColor.hexString);
            }
            """#
            
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
            body, p, ul, li {
                font-size: \#(uifont.pointSize)px;
                font-family: 'NotoSans';
                line-height: \#(uifont.pointSize * 1.361875)px;
            }
            </style>
            \#(html)
            """#
            let bundlePath = Bundle.main.bundlePath
            let bundleUrl = URL.init(fileURLWithPath: bundlePath)
            webView.loadHTMLString(newHtml, baseURL: bundleUrl)
        }
        
        if let onCallbackWebView = onCallbackWebView {
            onCallbackWebView(webView)
        }

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.scrollView.delegate = scrollViewDelegate
        webView.navigationDelegate = navigationDelegateWithOverrideUrl
        scrollViewDelegate.onScroll = onScroll
        navigationDelegateWithOverrideUrl.didAttemptToOpenUrlCallback = didAttemptToOpenUrlCallback
    }
    
    static func dismantleUIView(_ uiView: WKWebView, coordinator: ()) {
        uiView.scrollView.delegate = nil
        uiView.navigationDelegate = nil
        uiView.uiDelegate = nil
    }
    
    
}


