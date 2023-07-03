//
//  GenericFlexibleHeightWebView.swift
//  hkstp oneapp testing
//
//  Created by Leung Yu Wing on 20/4/2022.
//

import Foundation
import SwiftUI


struct GenericFlexibleHeightWebView : View
{
    @State private var htmlHeight : CGFloat = 0
    var htmlContent : String?
    var isDisableSelfSizing: Bool = false
    var htmlContentHeightExtra: CGFloat = 80

    
    var openUrl_shouldShowLeaveAppAlert: Bool? = true
    var openUrl_leaveAppAlert_title: String? = nil
    var openUrl_leaveAppAlert_message: String? = nil
    var didAttemptToOpenUrlCallback: ((
        _ url: URL
    ) -> (Bool))? = nil

    
    var body: some View {
        
        TP1AppWebView(
            viewItem: AppWebViewItem(
                title: nil,
                isSelfSizable: true,
                html: """
<style>
figure.image {
    margin: 0;
}
figure.image > img {
    width: 100%;
}
</style>
\(htmlContent ?? "")

""",
                isDisableSelfSizing: isDisableSelfSizing,
                htmlContentHeightExtra: htmlContentHeightExtra,
                didGetHeightCallback: { val in
                    htmlHeight = val
                },
                openUrl_shouldShowLeaveAppAlert: openUrl_shouldShowLeaveAppAlert,
                openUrl_leaveAppAlert_title: openUrl_leaveAppAlert_title,
                openUrl_leaveAppAlert_message: openUrl_leaveAppAlert_message,
                didAttemptToOpenUrlCallback: didAttemptToOpenUrlCallback
            )
        )
            .frame(height: htmlHeight)
    }
}

