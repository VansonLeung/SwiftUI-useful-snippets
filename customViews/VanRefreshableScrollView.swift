//
//  VanRefreshableScrollView.swift
//  hkstp oneapp testing
//
//  Created by van on 13/7/2022.
//

import Foundation
import SwiftUI
import Combine
import Introspect


struct VanTransitionViewModifier: ViewModifier {
    
    struct VanTransitionView<Content: View>: View {
        
        @Binding var isShow: Bool
        @Binding var triggerShowNow: Bool
        @Binding var triggerHideNow: Bool
        @State var opacity: CGFloat = 0
        @Binding var setOpacity: CGFloat
        @State var offsetY: CGFloat = 0
        @Binding var setOffsetY: CGFloat

        var content : () -> Content
        var body: some View {
            ZStack {
                if isShow {
                    content()
                        .opacity(opacity)
                        .frame(height: 50 * (opacity < 0 ? 0 : opacity), alignment: .center)
                        .offset(x: 0, y: -75 - 0 + offsetY / 1.2)
                }
            }
            .onLoad {
                if isShow {
                    opacity = 1.0
                }
            }
            .onChange(of: setOpacity, perform: { newValue in
                opacity = setOpacity
            })
            .onChange(of: triggerShowNow) { newValue in
                if triggerShowNow
                {
                    triggerShowNow = false
                    isShow = true
                    withAnimation {
                        opacity = 1.0
                    }
                }
            }
            .onChange(of: triggerHideNow) { newValue in
                if triggerHideNow
                {
                    triggerHideNow = false
                    withAnimation {
                        opacity = -0.01
                    }
                }
            }
            .onChange(of: opacity) { newValue in
                if opacity == -0.01
                {
                    opacity = 0
                    isShow = false
                }
            }
            .onChange(of: setOffsetY) { newValue in
                if abs(offsetY - newValue) >= 20 {
                    withAnimation(.default) {
                        offsetY = newValue
                    }
                } else {
                    offsetY = newValue
                }
            }
        }
    }
    
    @Binding var isShow: Bool
    @Binding var triggerShowNow: Bool
    @Binding var triggerHideNow: Bool
    @Binding var setOpacity: CGFloat
    @Binding var setOffsetY: CGFloat
    
    func body(content: Content) -> some View {
        VanTransitionView(
            isShow: $isShow,
            triggerShowNow: $triggerShowNow,
            triggerHideNow: $triggerHideNow,
            setOpacity: $setOpacity,
            setOffsetY: $setOffsetY
        ) {
                content
        }
    }
}


struct VanRefreshableScrollView<Content: View>: View {
    
    class ScrollViewObserver: NSObject, ObservableObject, UIScrollViewDelegate
    {
        @Published var isDragging: Bool = false
        @Published var isRunningPullToRefresh: Bool = false
        @Published var isSatifyPullToRefresh: Bool = false
        @Published var isBusyPullToRefresh: Bool = false
        var offsetY: CGFloat = 0
        @Published var pullToRefreshPlaceholderHeight: CGFloat = 0
        var __scrollView: UIScrollView?
        var onRefresh: (( _ completion: (@escaping () -> Void)  ) -> Void)?
        
        func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            __scrollView = scrollView
            isDragging = true
            isRunningPullToRefresh = true
        }
        
        func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
            __scrollView = scrollView
            if isDragging {
                isDragging = false
                tryPullToRefresh(scrollView: scrollView)
            }
        }
        
        func updateOffsetY(f : CGFloat)
        {
            offsetY = f
            if isDragging {
                
                if offsetY >= 0 {
                    self.pullToRefreshPlaceholderHeight = offsetY / 2
                }
                else {
                    self.pullToRefreshPlaceholderHeight = 0
                }
                
                
                if offsetY >= 115 {
                    isSatifyPullToRefresh = true
                } else {
                    isSatifyPullToRefresh = false
                }
                
//                if offsetY >= 125 {
//                    isSatifyPullToRefresh = true
//
//                    if let __scrollView = __scrollView {
//                        if isDragging {
//                            isDragging = false
//                            tryPullToRefresh(scrollView: __scrollView)
//                        }
//                    }
//                }
                

            }
        }
        
        func tryPullToRefresh(scrollView: UIScrollView)
        {
            if isSatifyPullToRefresh
            {
                isBusyPullToRefresh = true
                isSatifyPullToRefresh = false
                withAnimation(.easeInOut(duration: 0.25)) {
                    self.pullToRefreshPlaceholderHeight = 85
                }
                
                if let onRefresh = onRefresh {
                    onRefresh {
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            withAnimation(.default) {
                                self.pullToRefreshPlaceholderHeight = 0
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                                self.isBusyPullToRefresh = false
                                self.isRunningPullToRefresh = true
                            }
                        }

                    }
                }
                
            }
            else
            {
                isRunningPullToRefresh = false
                withAnimation(.default) {
                    self.pullToRefreshPlaceholderHeight = 0
                }
            }
        }
    }
    
    
    class ScrollViewRefreshViewObserver: ObservableObject
    {
        @Published var isShow: Bool = true
        @Published var triggerShowNow: Bool = false
        @Published var triggerHideNow: Bool = false
        @Published var setOpacity: CGFloat = 0
    }
    
    
    
    struct RefreshView: View {
        @Binding var offsetY: CGFloat
        @Binding var isAnimating: Bool
        @Binding var isRunningPullToRefresh: Bool

        var refreshIcon : String
        var refreshHint : String
        var isDisableRefreshHint : Bool = false
        var isNegativeColor : Bool = false

        var body: some View {
            ZStack {
//                ActivityIndicator(isAnimating: .constant(true), style: .large)
//                    .opacity(0.01 * offsetY)
                if isRunningPullToRefresh {
                    if isAnimating || isDisableRefreshHint {
                        ActivityIndicator(isAnimating: .constant(true), style: isNegativeColor ? .whiteLarge : .large)
                            .opacity(0.01 * offsetY)
                            .debugFrameSize()
                            .offset(x: 0, y: 24)
                    } else {
                        VStack {
                            Icon(icon: refreshIcon, iconSize: 32)
                                .rotationEffect(.degrees(-offsetY * 2))
                            Text(refreshHint)
                                .modifier(TP1AppTextViewModifier(viewElementStyles: .shared, typography: .en_caption_caption_reg, fontColor: .notes))
                        }
                        .offset(x: 0, y: 20)
                        .opacity(0.0 + (0.5 * 0.01 * offsetY))
                        .debugFrameSize()
                    }
                }
            }
            .padding()
        }
    }
    
    
    
    
    
    @StateObject private var svObs = ScrollViewObserver()
    @StateObject private var srObs = ScrollViewRefreshViewObserver()
    @StateObject private var stObs = ScrollViewTopOffsetPublishedObserver()

    var debug : Bool? = false

    var useInputOffsetY : Bool = false
    var inputOffsetY : CGFloat = 0
    
    var refreshFixedOffsetY : CGFloat = 0
    var refreshIcon : String = "ic_mg_information_history"
    var refreshHint : String = "Pull to refresh"
    var isDisableRefreshHint : Bool = false
    var isNegativeColor : Bool = false
    var onRefresh : (( _ completion: (@escaping () -> Void)  ) -> Void)?
    
    var content : () -> Content
    
    var body: some View {
        ZStack {
            if true || Constants.getInstance().shouldDebugShowAllExperimentalElements()
            {

                if !useInputOffsetY {
                    ScrollView {
                        Spacer()
                        .frame(height: svObs.pullToRefreshPlaceholderHeight)
                        content()
                            .modifier(ScrollViewTopOffsetPublishedAnchor(
                                name: "_van_refreshable_scroll",
                                stObs: stObs))
                    }
                    .modifier(ScrollViewTopOffsetRoot(name: "_van_refreshable_scroll"))
                    .onChange(of: stObs.offsetY) { newValue in
                        svObs.updateOffsetY(f: newValue)
                    }
                    .introspectScrollView { sv in
                        sv.delegate = svObs
                    }
                    .onLoad {
                        if let onRefresh = onRefresh {
                            svObs.onRefresh = onRefresh
                        }
                    }
                } else {
                    ScrollView {
                        Spacer()
                        .frame(height: svObs.pullToRefreshPlaceholderHeight)
                        content()
                    }
                    .onChange(of: inputOffsetY) { newValue in
                        svObs.updateOffsetY(f: newValue)
                    }
                    .introspectScrollView { sv in
                        sv.delegate = svObs
                    }
                    .onLoad {
                        if let onRefresh = onRefresh {
                            svObs.onRefresh = onRefresh
                        }
                    }
                }
                
                if debug == true {
                    VStack {
                        Text("svObs \(svObs.isDragging ? "T":"F")   ")
                        Text("srObs \(srObs.isShow ? "T":"F")")
                        TP1PageSpacer(h: 150)
                        Text("stObs \(stObs.offsetY ) ")

                        Button {
                            srObs.triggerShowNow = true
                        } label: {
                            Text("Show indicator")
                        }
        
                        Button {
                            srObs.triggerHideNow = true
                        } label: {
                            Text("Hide indicator")
                        }
                    }
                }
                
                
                VStack {
                    RefreshView(
                        offsetY: $stObs.offsetY,
                        isAnimating: $svObs.isBusyPullToRefresh,
                        isRunningPullToRefresh: .constant(true),
                        refreshIcon: refreshIcon,
                        refreshHint: refreshHint,
                        isDisableRefreshHint: isDisableRefreshHint,
                        isNegativeColor: isNegativeColor
                    )
                        .modifier(VanTransitionViewModifier(
                            isShow: $srObs.isShow,
                            triggerShowNow: $srObs.triggerShowNow,
                            triggerHideNow: $srObs.triggerHideNow,
                            setOpacity: $srObs.setOpacity,
                            setOffsetY: $stObs.offsetY
                        ))
                    Spacer()
                }
                .offset(x: 0, y: refreshFixedOffsetY)

                
            }
            else
            {
                ScrollView {
                    content()
                }
            }
            

        }
    }
    
    
    
}

struct __DEMO_VRSV: View {
    
    @State var appearTimes : Int = 0
    @State var loadTimes : Int = 0
    
    var body: some View {
        
        NavigationView {
            ZStack {
                VanRefreshableScrollView(
                    debug: true,
                    useInputOffsetY: false,
                    inputOffsetY: 0,
                    refreshIcon: "ic_mg_information_history",
                    refreshHint: "Pull to refresh",
                    onRefresh: { completion in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            completion()
                        }
                    }) {
                    
                    LazyVStack(spacing: 0) {
                        ForEach(0 ..< 100) {i in
                            TP1SectionTitleView(
                                title: "sdfasdf \(i)")
                            .onAppear {
                                appearTimes += 1
                            }
                            .onLoad {
                                loadTimes += 1
                            }
                        }
                    }
                    .debugFrameSize()

                }
                
                VStack {
                    TP1PageSpacer(h: 50)
                    Text("\(appearTimes)")
                    Text("\(loadTimes)")
                }
                
                ZStack {}
                    .navigationBarGeneralOpaque(title: "VRVS", iconRight: nil, actionRight: nil)
            }
        }


    }
}

struct __DEMO_VRSV_Previews: PreviewProvider {
    static var previews: some View {
        __DEMO_VRSV()
    }
}


