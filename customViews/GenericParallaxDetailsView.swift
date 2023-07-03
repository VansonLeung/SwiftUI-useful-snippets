//
//  GenericParallaxDetailsView.swift
//  hkstp oneapp testing
//
//  Created by Leung Yu Wing on 20/4/2022.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI



struct GenericParallaxDetailsView<Content: View, BottomContent: View> : View
{
    @State private var scrollViewContentOffset = CGFloat(0) // Content offset available to use
    @State private var navBarHeight = CGFloat(0) // Content offset available to use
    
    @State var hideNavigationBar: Bool = true
    
    var bannerImgUrl : String?
    var noBannerTitle : String?
    var onClickBackBtn : (() -> Void)?
    var content : () -> Content
    var bottomContent : () -> BottomContent
    

    func getParallaxImageHeight(geometry : GeometryProxy) -> CGFloat {
        if geometry.frame(in: .global).minY <= 0 {
            print("A \(geometry.size.width / 16 * 9)")
            return geometry.size.width / 16 * 9
        } else {
            print("B \(geometry.size.width / 16 * 9 + geometry.frame(in: .global).minY)")
            return geometry.size.width / 16 * 9 + geometry.frame(in: .global).minY
        }
    }
    
    func getParallaxImageOffsetY(geometry : GeometryProxy) -> CGFloat {
        if geometry.frame(in: .global).minY <= 0 {
            print("C \(geometry.frame(in: .global).minY / 9)")
//            return geometry.frame(in: .global).minY / 9
            return 0
        } else {
            print("D \(-geometry.frame(in: .global).minY)")
            return -geometry.frame(in: .global).minY
        }
    }
     
    var body: some View {

        VStack {
            TrackableScrollView(contentOffset: $scrollViewContentOffset) {
                if let img = bannerImgUrl?.asPercentEncoded(), img.trimmingCharacters(in: .whitespaces) != "" {
                    ZStack {
                        GeometryReader { geometry in
                            WebImage(url: URL(string: img))
                                .onSuccess { image, data, cacheType in
                                    // Success
                                    // Note: Data exist only when queried from disk cache or network. Use `.queryMemoryData` if you really need data
                                }
                                .resizable() // Resizable like SwiftUI.Image, you must use this modifier or the view will use the image bitmap size
        //                        .placeholder {
        //                            Rectangle().foregroundColor(.gray)
        //                        }
                                .indicator(.activity) // Activity Indicator
        //                        .transition(.fade(duration: 0.5)) // Fade Transition with duration
                                .scaledToFill()
                                .frame(width: geometry.size.width,
                                       height: getParallaxImageHeight(geometry: geometry))
                                .offset(y: getParallaxImageOffsetY(geometry: geometry))

                        }
                        
                    }
                    .frame(height: UIScreen.main.bounds.width / 16 * 9)
                    .background(
                        Rectangle()
                            .fill(Color(UIColor.darkGray))
                    )
                } else {
                    ZStack {}
                        .frame(height: 64)
                }
                
                content()
            }
                .edgesIgnoringSafeArea(.top)
                .topSafeAreaInset(
                    
                    GeometryReader { geometry in
                        if hideNavigationBar {
                            
                            let isTransparent = (scrollViewContentOffset < (geometry.size.width / 16 * 9 - (geometry.safeAreaInsets.top * 1.5) - navBarHeight)) && (
                                (bannerImgUrl ?? "").trimmingCharacters(in: .whitespaces) != "")
                            
                            let hideNavTitle = (
                                (bannerImgUrl ?? "").trimmingCharacters(in: .whitespaces) != "")
                            
                            ZStack() {
                                VStack() {
                                    LinearGradient(colors: [
                                        Color(UIColor.fromHexString6(str: PaletteHelper.hex_bgBlack2)).opacity(isTransparent ? 0.65 : 0),
                                        Color(UIColor.fromHexString6(str: PaletteHelper.hex_bgBlack2)).opacity(0),
                                    ], startPoint: .top, endPoint: .bottom)
                                        .transition(.asymmetric(insertion: .opacity, removal: .opacity))
                                }
                                .frame(height: navBarHeight + 50, alignment: .leading)
                                .edgesIgnoringSafeArea(.top)

                                HStack() {
                                    Button(action: {
                                        if let onClickBackBtn = onClickBackBtn {
                                            onClickBackBtn()
                                        }
                                    }) {
                                        Image(systemName: "chevron.left")
                                            .scaleEffect(0.83)
                                            .font(Font.title.weight(.medium))
                                            .frame(width: 44, alignment: .leading)
                                            .shadow(color: Color(UIColor.palette_bgBlack2()), radius: 4, x: 0, y: 1)
                                            .foregroundColor(
                                                isTransparent ? (
                                                    Color(UIColor.palette_bgWhite())
                                                ) : (
                                                    Color(UIColor.palette_bgBlack2())
                                                ))
                                            
                                    }
                                    Spacer()
                                    
                                    if !hideNavTitle {
                                        Text(noBannerTitle ?? "")
                                            .font(.headline.weight(.medium))
                                    }

                                    Spacer()
                                    
                                    Spacer()
                                        .frame(width: 44, alignment: .leading)
                                }
                                .background(NavBarAccessor {navBar in
                                    navBarHeight = navBar.frame.height
                                })
                                .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                                .frame(height: navBarHeight)
                                
                                
                                
                                VStack {
                                    Spacer()
                                    Rectangle()
                                        .fill(isTransparent ? (
                                            .gray.opacity(0.0)
                                        ) : (
                                            .gray.opacity(0.4)
                                        ))
                                        .transition(.asymmetric(insertion: .opacity, removal: .opacity))
                                        .frame(height: 1, alignment: .bottom)
                                }
                                .frame(height: navBarHeight)
                                
                            }
                            .frame(height: navBarHeight)
                            .padding(EdgeInsets(top: geometry.safeAreaInsets.top, leading: 0, bottom: 0, trailing: 0))
                            .background(
                                Rectangle()
                                    .fill(isTransparent ? (
                                        Color(UIColor.palette_bgWhite2())
                                            .opacity(0.0)
                                    ) : (
                                        Color(UIColor.palette_bgWhite2())
                                            .opacity(1.0)
                                    ))
                                    .transition(.asymmetric(insertion: .opacity, removal: .opacity))
                            )
                            .offset(y: -geometry.safeAreaInsets.top)
                            .animation(.easeInOut(duration: 0.0), value: isTransparent)  // << here !!
        //                    .frame(minHeight: navBarHeight + geometry.safeAreaInsets.top + geometry.safeAreaInsets.top)
        //                            .frame(height: navigationBar.frame.height)
        //                    .edgesIgnoringSafeArea(.top)

        //                    .frame(height: 0)
                        }
                    }
                )

            
            
            bottomContent()

        }
    }
}

