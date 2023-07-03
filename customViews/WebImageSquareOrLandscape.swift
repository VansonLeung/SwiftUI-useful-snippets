//
//  WebImageSquareOrLandscape.swift
//  hkstp oneapp testing
//
//  Created by van on 30/9/2022.
//

import SwiftUI
import SDWebImageSwiftUI

struct WebImageSquareOrLandscape: View {
    var url: URL
    
    @State var height : CGFloat? = nil
    @State var opacity : CGFloat = 0
    
    var getHeight: CGFloat {
        return height ?? UIScreen.main.bounds.width * 375 / 375
    }
    
    var getHeightStatic: CGFloat {
        return height ?? UIScreen.main.bounds.width * 375 / 375
    }
    
    var body: some View {
    
        VStack(spacing: 0) {
            WebImage(url: url)
                .onSuccess(perform: { platformImage, data, cacheType in
                    DispatchQueue.main.async {
                        height = min(
                            UIScreen.main.bounds.width * 375 / 375,
                            UIScreen.main.bounds.width * platformImage.size.height / platformImage.size.width
                        )
                        opacity = 1
                    }
                })
                .resizable()
                .scaledToFill()
                .background(TP1ViewElementStyles.shared.activeColorTheme.color_content_notes)
                .frame(
                    width: UIScreen.main.bounds.width,
                    height: getHeightStatic)
                .opacity(opacity)
                .clipped()
            
            Spacer()
        }
        .frame(
            width: UIScreen.main.bounds.width,
            height: getHeight)
        .clipped()
        .animation(.easeOut(duration: 0), value: getHeightStatic)
        .animation(.default, value: getHeight)
        .animation(.default, value: opacity)

    }
}


struct WebImageSquareOrLandscapeBindHeightOpacity: View {
    var url: URL
    
    @Binding var height : CGFloat?
    @Binding var opacity : CGFloat
    
    var getHeight: CGFloat {
        return height ?? UIScreen.main.bounds.width * 375 / 375
    }
    
    var getHeightStatic: CGFloat {
        return height ?? UIScreen.main.bounds.width * 375 / 375
    }
    
    var body: some View {
    
        VStack(spacing: 0) {
            WebImage(url: url)
                .onSuccess(perform: { platformImage, data, cacheType in
                    DispatchQueue.main.async {
                        height = min(
                            UIScreen.main.bounds.width * 375 / 375,
                            UIScreen.main.bounds.width * platformImage.size.height / platformImage.size.width
                        )
                        opacity = 1
                    }
                })
                .resizable()
                .scaledToFill()
                .background(TP1ViewElementStyles.shared.activeColorTheme.color_content_notes)
                .frame(
                    width: UIScreen.main.bounds.width,
                    height: getHeightStatic)
                .opacity(opacity)
                .clipped()
            
            Spacer()
        }
        .frame(
            width: UIScreen.main.bounds.width,
            height: getHeight)
        .clipped()
        .animation(.easeOut(duration: 0), value: getHeightStatic)
        .animation(.default, value: getHeight)
        .animation(.default, value: opacity)

    }
}



