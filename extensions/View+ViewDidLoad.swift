//
//  View+ViewDidLoad.swift
//  hkstp oneapp testing
//
//  Created by Vanson YW Leung on 29/12/2021.
//

import Foundation
import SwiftUI

extension View {

    func onLoad(perform action: (() -> Void)? = nil) -> some View {
        modifier(ViewDidLoadModifier(perform: action))
    }

}
