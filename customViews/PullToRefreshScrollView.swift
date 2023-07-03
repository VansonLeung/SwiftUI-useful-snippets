//
//  PullToRefreshScrollView.swift
//  hkstp oneapp testing
//
//  Created by Leung Yu Wing on 15/2/2022.
//

import Foundation
import SwiftUI



struct PullToRefreshScrollView<ROOTVIEW>: UIViewRepresentable where ROOTVIEW: View {
    
    @Binding var isLoading: Bool

    var width : CGFloat, height : CGFloat
    let handlePullToRefresh: () -> Void
    let rootView: () -> ROOTVIEW
    
    func makeCoordinator() -> Coordinator<ROOTVIEW> {
        let control = UIScrollView(frame: CGRect.zero)
        control.refreshControl = UIRefreshControl()
        return Coordinator(self, scrollView: control, rootView: rootView, handlePullToRefresh: handlePullToRefresh)
    }

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = context.coordinator.scrollView
        scrollView.refreshControl?.addTarget(context.coordinator, action:
            #selector(Coordinator.handleRefreshControl),
                                          for: .valueChanged)

        let childView = UIHostingController(rootView: rootView() )
        childView.view.frame = CGRect(x: 0, y: 0, width: width, height: height)
        scrollView.contentSize = CGSize(width: width, height: height)
        scrollView.addSubview(childView.view)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = false
        return scrollView
    }

    func updateUIView(_ uiView: UIScrollView, context: Context) {
        if !isLoading {
            context.coordinator.scrollView.refreshControl?.endRefreshing()
        }
        
        context.coordinator.scrollView.subviews[1].frame = CGRect(
            x: 0,
            y: 0,
            width: width,
            height: height
        )
        
        context.coordinator.scrollView.contentSize = CGSize(
            width: width,
            height: height
        )
    }

    class Coordinator<ROOTVIEW>: NSObject where ROOTVIEW: View {
        var control: PullToRefreshScrollView
        var scrollView: UIScrollView
        var handlePullToRefresh: () -> Void
        var rootView: () -> ROOTVIEW

        init(_ control: PullToRefreshScrollView, scrollView: UIScrollView, rootView: @escaping () -> ROOTVIEW, handlePullToRefresh: @escaping () -> Void) {
            self.control = control
            self.scrollView = scrollView
            self.handlePullToRefresh = handlePullToRefresh
            self.rootView = rootView
        }

        @objc func handleRefreshControl(sender: UIRefreshControl) {
            handlePullToRefresh()
        }
    }
}


