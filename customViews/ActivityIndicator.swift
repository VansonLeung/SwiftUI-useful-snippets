//
//  ActivityIndicator.swift
//  hkstp oneapp testing
//
//  Created by Vanson YW Leung on 29/12/2021.
//

import Foundation
import SwiftUI

struct ActivityIndicator: UIViewRepresentable {

    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style

    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        let av = UIActivityIndicatorView(style: style)
        if style == .white || style == .whiteLarge {
            av.color = UIColor.white
        }
        return av
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}
