//
//  CleanWebView.swift
//  hkstp oneapp testing
//
//  Created by van on 22/9/2022.
//

import Foundation
import SwiftUI
import WebKit


extension WKWebView {
    
    func onDismiss(completion: ( () -> Void)?) {
        self.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
            WebViewConfigurationCookieSupport().setData(cookies, key: "cookies")
            if let completion = completion {
                completion()
            }
        }
    }
}


class FullScreenWKWebView: WKWebView {
    override var safeAreaInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}

class WebViewConfigurationCookieSupport: NSObject {
    
    let group = DispatchGroup()

    func setData(_ value: Any, key: String) {
        let ud = UserDefaults.standard
        let archivedPool = NSKeyedArchiver.archivedData(withRootObject: value)
        ud.set(archivedPool, forKey: key)
    }

    func getData<T>(key: String) -> T? {
        let ud = UserDefaults.standard
        if let val = ud.value(forKey: key) as? Data,
            let obj = NSKeyedUnarchiver.unarchiveObject(with: val) as? T {
            return obj
        }
        
        return nil
    }
    
    func configurationForWebView(_ completion: @escaping (WKWebViewConfiguration) -> Void) {
                
        let configuration = WKWebViewConfiguration()
        
        //Need to reuse the same process pool to achieve cookie persistence
        let processPool: WKProcessPool

        if let pool: WKProcessPool = getData(key: "pool")  {
            processPool = pool
        }
        else {
            processPool = WKProcessPool()
            setData(processPool, key: "pool")
        }

        configuration.processPool = processPool
        
        if let cookies: [HTTPCookie] = getData(key: "cookies") {
            
            for cookie in cookies {
                
                group.enter()
                configuration.websiteDataStore.httpCookieStore.setCookie(cookie) {
                    print("Set cookie = \(cookie) with name = \(cookie.name)")
                    self.group.leave()
                }
            }
            
        }
        
        group.notify(queue: DispatchQueue.main) {
            completion(configuration)
        }
    }
    
}



class WebViewUIDelegate : NSObject, WKUIDelegate
{
    @available(iOS 15, *)
    func webView(
        _ webView: WKWebView,
        requestDeviceOrientationAndMotionPermissionFor origin: WKSecurityOrigin,
        initiatedByFrame frame: WKFrameInfo,
        decisionHandler: @escaping (WKPermissionDecision) -> Void)
    {
        decisionHandler(.grant)
    }
    
    @available(iOS 15, *)
    func webView(
        _ webView: WKWebView,
        requestMediaCapturePermissionFor origin: WKSecurityOrigin,
        initiatedByFrame frame: WKFrameInfo,
        type: WKMediaCaptureType,
        decisionHandler: @escaping (WKPermissionDecision) -> Void)
    {
        decisionHandler(.grant)
    }
}

class WebViewNavigationDelegate : NSObject, WKNavigationDelegate
{
    var onCallbackSpecialTag : ((String?) -> Void)?
    
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
}


struct CleanWebView: UIViewRepresentable {

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
    
    let navigationDelegate : WebViewNavigationDelegate = WebViewNavigationDelegate()
    let uiDelegate : WebViewUIDelegate = WebViewUIDelegate()
    let scrollViewDelegate: WebViewScrollViewDelegate = WebViewScrollViewDelegate()

    func makeUIView(context: Context) -> WKWebView {
        var wv : WKWebView?
        
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
        webView.navigationDelegate = navigationDelegate
        webView.scrollView.delegate = scrollViewDelegate
        scrollViewDelegate.onScroll = onScroll
        navigationDelegate.onCallbackSpecialTag = { tag in
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
        scrollViewDelegate.onScroll = onScroll
    }
    
    static func dismantleUIView(_ uiView: WKWebView, coordinator: ()) {
        uiView.scrollView.delegate = nil
        uiView.navigationDelegate = nil
        uiView.uiDelegate = nil
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
