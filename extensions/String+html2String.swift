//
//  String+html2String.swift
//  hkstp oneapp testing
//
//  Created by Leung Yu Wing on 22/2/2022.
//

import Foundation
import UIKit

extension Data {
    var html2AttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: self, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print("error:", error)
            return nil
        }
    }
    var html2String: String { html2AttributedString?.string ?? "" }
}

extension StringProtocol {
    var html2AttributedString: NSAttributedString? {
        Data(utf8).html2AttributedString
    }
    
    var htmlStringBootstrap: String {
        let lined_msg = self
//            .replacingOccurrences(of: "<br>", with: "\n")
//            .replacingOccurrences(of: "<br/>", with: "\n")
//            .replacingOccurrences(of: "<br/ >", with: "\n")
//            .replacingOccurrences(of: "<br />", with: "\n")
//            .replacingOccurrences(of: "hsl(60,75%,60%)", with: "rgb(100,15,52)")
        let m_msg = String(format: "<span style=\"font-family: '-apple-system', Helvetica;  color: #666666  \">\(lined_msg)</span>" )
        return m_msg
    }
    
    var htmlStringBootstrapDarkMode: String {
        let lined_msg = self
//            .replacingOccurrences(of: "<br>", with: "\n")
//            .replacingOccurrences(of: "<br/>", with: "\n")
//            .replacingOccurrences(of: "<br/ >", with: "\n")
//            .replacingOccurrences(of: "<br />", with: "\n")
//            .replacingOccurrences(of: "hsl(60,75%,60%)", with: "rgb(100,15,52)")
        let m_msg = String(format: "<span style=\"font-family: '-apple-system', Helvetica;  color: #FFFFFF  \">\(lined_msg)</span>" )
        return m_msg
    }
    
    var html2AppleFontAttributedString: NSAttributedString? {
        return Data(htmlStringBootstrap.utf8).html2AttributedString
    }
    
    var html2AppleFontAttributedStringDarkMode: NSAttributedString? {
        return Data(htmlStringBootstrapDarkMode.utf8).html2AttributedString
    }
    
    var html2String: String {
        html2AttributedString?.string ?? ""
    }
}
