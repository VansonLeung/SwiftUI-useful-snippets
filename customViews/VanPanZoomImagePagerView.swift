//
//  VanPanZoomImagePagerView.swift
//  hkstp oneapp testing
//
//  Created by van on 18/7/2022.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI


struct VanPanZoomImagePagerView: View {
    
    @State private var zoomScale : CGFloat = 1.0
    @State private var page: CGFloat = 0.0
    @State private var pageExtra: CGFloat = 0.0
    
    var initialPage: Int = 0
    var imageModels: [ImageModel]
    
    struct PanZoomImage: View {
        
        let model : ImageModel
        var viewWidth: CGFloat
        var viewHeight: CGFloat
        let onZoomChange: ((_ scrollView : UIScrollView) -> Void)?

        var body: some View {
        
            VanPanZoomImageViewSwiftUI(
                imageUrl: model.imageUrl,
                onZoomChange: { scrollView in
                    if let onZoomChange = onZoomChange {
                        onZoomChange(scrollView)
                    }
                }
            )
                .frame(width: viewWidth, height: viewHeight)
        }
    }
    
    
    public class ImageModel: ObservableObject, Identifiable {
        let id = UUID().uuidString
        let imageUrl: String

        init(imageUrl: String) {
            self.imageUrl = imageUrl
        }
    }
    
        
    
    
    struct PageContentView: View {
        
        var viewWidth: CGFloat
        var viewHeight: CGFloat
        var imageModels : [ImageModel]
        var onZoomChange: ((_ scrollView: UIScrollView) -> Void)?
        
        var body: some View {
            
            ForEach(imageModels) {e in
                VanPanZoomImageViewSwiftUI(
                    imageUrl: e.imageUrl,
                    onZoomChange: { scrollView in
                        if let onZoomChange = onZoomChange {
                            onZoomChange(scrollView)
                        }
                    }
                )
                    .frame(width: viewWidth, height: viewHeight)
            }
            .onAppear {
                print("ASDSBDSFSDF")
            }
        }
    }
    
    
    
    
    
    
    struct PageView: View {
        @Binding var zoomScale : CGFloat
        @Binding var page: CGFloat
        @Binding var pageExtra: CGFloat
        
        var viewWidth: CGFloat
        var viewHeight: CGFloat
        
        var imageModels: [ImageModel]
        var total_pages: CGFloat
        
        var body: some View {
            ZStack {
                
                ZStack {
                    LazyHStack(spacing: 0) {
                        PageContentView(
                            viewWidth: viewWidth,
                            viewHeight: viewHeight,
                            imageModels: imageModels
                        ) { scrollView in
                            zoomScale = scrollView.zoomScale
                            print(zoomScale)
                        }
                    }
                    .frame(width: viewWidth * total_pages)
                    
                    .background(Rectangle().fill(.black))
                    .position(
                        x: viewWidth * total_pages / 2,
                        y: viewHeight / 2)
                    .offset(
                        x: (total_pages <= 1 ? (viewWidth * 0) : (viewWidth * -(page + pageExtra)) ),
                        y: 0)
                    
                    .gesture(
                        fingerDrag
//                            .simultaneously(with: zoomDrag)
//                            .exclusively(before: doubleTapZoom)
                        )
                }
                

                
                VStack {
//                    Text("\(zoomScale)")
//                    Text("\(zoomScaleExtra)")
//                    Text("\(page)")
//                    Text("\(pageExtra)")
                }
                .allowsHitTesting(false)
            }
            .frame(width: viewWidth, height: viewHeight)
        }
        
        
        @GestureState var dg = CGSize.zero

        var fingerDrag: some Gesture { // 2
            DragGesture()
                .updating($dg, body: { value, state, transaction in
                    print("DG", value, state, transaction)
                })
                .onChanged { value in
                    print(zoomScale)
                    if zoomScale > 1.0 {
    //                    self.offsetExtra = CGPoint(
    //                        x: value.location.x - value.startLocation.x,
    //                        y: value.location.y - value.startLocation.y)

                    } else {
                        self.pageExtra = -((value.location.x - value.startLocation.x) / viewWidth)
                    }
                }
                .onEnded { value in
                    if zoomScale > 1.0 {
    //                    self.offset = CGPoint(
    //                        x: self.offset.x + self.offsetExtra.x,
    //                        y: self.offset.y + self.offsetExtra.y)
    //                    self.offsetExtra = .zero
                    } else {
                        withAnimation {
                            if self.pageExtra < -0.2 {
                                self.page -= 1
                            }
                            else if self.pageExtra > 0.2 {
                                self.page += 1
                            }
                            self.pageExtra = 0

                            self.page = round(self.page)
                            if self.page < 0 {
                                self.page = 0
                            }
                            else if self.page >= total_pages {
                                self.page = total_pages - 1
                            }
                        }
                    }
                }
        }
        
//        var doubleTapZoom: some Gesture { // 2
//            TapGesture(count: 2)
//                .onEnded { _ in
//                    withAnimation {
//                        self.zoomScaleExtra = 0
//                        if self.zoomScale <= 1.5 {
//                            self.zoomScale = 2.5
//                        } else if self.zoomScale > 1.5 {
//                            self.zoomScale = 1.0
//                        }
//                    }
//                }
//        }
//
//        @GestureState var mzd : MagnificationGesture.Value = 1.0
//
//        var zoomDrag: some Gesture { // 2
//            MagnificationGesture()
//                .updating($mzd, body: { value, state, transaction in
//                    print("MZD", value, state, transaction)
//                })
//                .onChanged { value in
//                    self.zoomScaleExtra = (value - 1) * 1.6
//                }
//                .onEnded { value in
//                    self.zoomScale = self.zoomScale + self.zoomScaleExtra
//                    self.zoomScaleExtra = 0
//                    withAnimation {
//                        if self.zoomScale < 1.0 {
//                            self.zoomScale = 1.0
//                        } else if self.zoomScale > 2.5 {
//                            self.zoomScale = 2.5
//                        }
//                    }
//                }
//        }
    }
    
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                PageView(
                    zoomScale: $zoomScale,
                    page: $page,
                    pageExtra: $pageExtra,
                    viewWidth: geometry.size.width,
                    viewHeight: geometry.size.height,
                    imageModels: imageModels,
                    total_pages: CGFloat(imageModels.count)
                )
            }
        }
        .onLoad {
            page = CGFloat(initialPage)
        }
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ZStack {
                VanPanZoomImagePagerView(
                    initialPage: 0,
                    imageModels: [
                        VanPanZoomImagePagerView.ImageModel(imageUrl: "https://images.theconversation.com/files/443350/original/file-20220131-15-1ndq1m6.jpg?ixlib=rb-1.1.0&rect=0%2C0%2C3354%2C2464&q=45&auto=format&w=926&fit=clip"),
                        VanPanZoomImagePagerView.ImageModel(imageUrl: "https://images.theconversation.com/files/168121/original/file-20170505-1693-ymh4bc.jpg?ixlib=rb-1.1.0&q=45&auto=format&w=1356&h=668&fit=crop"),
                        VanPanZoomImagePagerView.ImageModel(imageUrl: "https://c8.alamy.com/compit/c00jxf/alta-risoluzione-panorama-verticale-degli-interni-di-james-thompson-r-centro-chicago-illinois-stati-uniti-d-america-c00jxf.jpg"),
                        VanPanZoomImagePagerView.ImageModel(imageUrl: "https://previews.123rf.com/images/evgenyi/evgenyi1412/evgenyi141200041/34470658-gray-cat-isolated-on-white-background-vertical-photo-.jpg"),
                        VanPanZoomImagePagerView.ImageModel(imageUrl: "https://images.theconversation.com/files/443350/original/file-20220131-15-1ndq1m6.jpg?ixlib=rb-1.1.0&rect=0%2C0%2C3354%2C2464&q=45&auto=format&w=926&fit=clip"),
                        VanPanZoomImagePagerView.ImageModel(imageUrl: "https://images.theconversation.com/files/168121/original/file-20170505-1693-ymh4bc.jpg?ixlib=rb-1.1.0&q=45&auto=format&w=1356&h=668&fit=crop"),
                    ]
                )
                
                VStack {
                    TP1PageSpacer(h: TP1ViewElementStyles.shared.getSafeAreaInsetsTopHeight())
                    ZStack {}
                        .navigationBarGeneralTranslucent(title: "", iconRight: nil, actionRight: nil, iconRight2: nil, actionRight2: nil)
                        .debugFrameSize()
                }
                .background(Rectangle().fill(.red))
            }
            .asDetailsView(linkBundleObs: AppRootNavigationViewLinkBundleObs())
            .edgesIgnoringSafeArea(.all)
        }
//        PanZoomImageViewSwiftUI()
    }
}
