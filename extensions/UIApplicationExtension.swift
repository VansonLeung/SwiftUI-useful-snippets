//
//  UIApplicationExtension.swift
//  hkstp oneapp testing
//
//  Created by Leung Yu Wing on 19/1/2022.
//

import Foundation
import SwiftUI

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
