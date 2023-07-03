//
//  GenericLoadingView.swift
//  hkstp oneapp testing
//
//  Created by Leung Yu Wing on 8/4/2022.
//

import Foundation
import SwiftUI

struct GenericLoadingView: View {
    
    var style : UIActivityIndicatorView.Style = .medium
    
    @ViewBuilder
    var body: some View {
        
        HStack(alignment: .center) {
            Spacer()
            VStack(alignment: .center) {
                Spacer()
                Group {
                    ActivityIndicator(isAnimating: .constant(true), style: style)
                }
                Spacer()
            }
            Spacer()
        }
        .frame(
          minWidth: 0,
          maxWidth: .infinity,
          minHeight: 0,
          maxHeight: .infinity,
          alignment: .topLeading
        )
        .background(Color(UIColor.palette_bgWhite()))

    }
    
}
