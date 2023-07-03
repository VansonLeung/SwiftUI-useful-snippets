//
//  GenericPagerView.swift
//  hkstp oneapp testing
//
//  Created by Leung Yu Wing on 20/4/2022.
//

import Foundation
import SwiftUI

struct GenericScreenWidthPagerView<Content: View>: View {
    let pageCount: Int
    @Binding var currentIndex: Int
    @Binding var currentIndexPercent: CGFloat
    let content: () -> Content
    var autoScrollSeconds: Double = 0
    var isDisableGesture: Bool = false
    var isUseLowPriorityGesture: Bool = false

    init(pageCount: Int, currentIndex: Binding<Int>, currentIndexPercent: Binding<CGFloat>, autoScrollSeconds: Double, isDisableGesture: Bool = false, isUseLowPriorityGesture: Bool = false, @ViewBuilder content: @escaping () -> Content) {
        self.pageCount = pageCount
        self._currentIndex = currentIndex
        self._currentIndexPercent = currentIndexPercent
        self.autoScrollSeconds = autoScrollSeconds
        self.isDisableGesture = isDisableGesture
        self.isUseLowPriorityGesture = isUseLowPriorityGesture
        self.content = content
    }

    var body: some View {
        GeometryReader { geometry in
            GenericPagerView(
                 pageCount: pageCount,
                 currentIndex: $currentIndex,
                 currentIndexPercent: $currentIndexPercent,
                 autoScrollSeconds: autoScrollSeconds,
                 width: geometry.size.width,
                 isDisableGesture: isDisableGesture,
                 isUseLowPriorityGesture: isUseLowPriorityGesture,
                 content: content)
        }
    }
}



struct GenericPagerView<Content: View>: View {
    let pageCount: Int
    var sc_width : CGFloat = 0
    var sc_width_widthLastItemModifier : CGFloat = 0
    let autoScrollSeconds: Double
    
    let autoScrollTimer = Timer.publish(every: 0.03, on: .main, in: .common).autoconnect()
    @State var autoScrollCountupSeconds: Double = 0
    @State var isDragging: Bool = false

    @State var ignore: Bool = false
    @Binding var currentIndex: Int {
        didSet {
            if (!ignore) {
                currentFloatIndex = CGFloat(currentIndex)
            }
        }
    }
    @Binding var currentIndexPercent: CGFloat
    @State var currentFloatIndex: CGFloat = 0 {
        didSet {
            ignore = true
            currentIndex = max(min(max(Int(currentFloatIndex.rounded()), 0), self.pageCount - 1), 0)
            currentIndexPercent = currentFloatIndex
            ignore = false
        }
    }

    var isDisableGesture: Bool = false
    var isUseLowPriorityGesture: Bool = false

    let content: Content

    @GestureState private var offsetX: CGFloat = 0

    init(pageCount: Int, currentIndex: Binding<Int>, currentIndexPercent: Binding<CGFloat>, autoScrollSeconds: Double = 0, width: CGFloat, widthLastItemModifier: CGFloat = 0, isDisableGesture: Bool = false, isUseLowPriorityGesture: Bool = false, @ViewBuilder content: () -> Content) {
        self.pageCount = pageCount
        self._currentIndex = currentIndex
        self._currentIndexPercent = currentIndexPercent
        self.autoScrollSeconds = autoScrollSeconds
        self.sc_width = width
        self.sc_width_widthLastItemModifier = widthLastItemModifier
        self.isDisableGesture = isDisableGesture
        self.isUseLowPriorityGesture = isUseLowPriorityGesture
        self.content = content()
    }

    var ViewHolderContent: some View {
        ZStack {
            HStack(alignment: .top, spacing: 0) {
                self.content.frame(width: sc_width)
            }
            .frame(width: sc_width, alignment: .leading)
            .offset(x:
                        -CGFloat(self.currentFloatIndex) * sc_width
                        + ( (pageCount > 1 && currentIndex >= pageCount - 1) ? self.sc_width_widthLastItemModifier : 0 )
            )
            .offset(x: self.offsetX)
            .animation(.linear, value:offsetX)
//            Text("\(offsetX)\n\(currentIndex)\n\(pageCount)\n\(self.sc_width)\n\(self.sc_width_widthLastItemModifier)")
        }
    }
    
    @ViewBuilder
    var ViewHolder: some View {
        if isDisableGesture
        {
            ViewHolderContent
        }
        else if isUseLowPriorityGesture
        {
            ViewHolderContent
            .gesture(
                CustomDragGesture
            )
        }
        else
        {
            ViewHolderContent
            .highPriorityGesture(
                CustomDragGesture
            )
        }
    }
    
    var CustomDragGesture: some Gesture {
        DragGesture().updating(self.$offsetX) { value, state, transaction in
            print("A \(state) \(value.translation) ")
            if state == 0
            {
                if value.translation.height <= -10
                    || value.translation.height >= 10
                {
                    DispatchQueue.main.async {
                        self.isDragging = false
                        print("A 0.0 -> X")
                    }
                }
                else
                {
                    state = value.translation.width
                    print("A \(value.translation.width) \(transaction ) ")
                }
            }
            else
            {
                state = value.translation.width
                print("A \(value.translation.width) \(transaction ) ")
            }
        }
        .onChanged({ value in
            print("B \(value.translation.width)")
            self.isDragging = true
            self.autoScrollCountupSeconds = 0
            let offset = value.translation.width / sc_width
            let newIndex = CGFloat(self.currentFloatIndex) - offset
            self.currentIndexPercent = newIndex
            print(offset)
        })
        .onEnded({ (value) in
            let offset = value.translation.width / sc_width
            let offsetPredicted = value.predictedEndTranslation.width / sc_width
            let newIndex = CGFloat(self.currentFloatIndex) - offset
            
            self.currentFloatIndex = newIndex
            self.currentIndexPercent = currentFloatIndex
            self.isDragging = false
            self.autoScrollCountupSeconds = 0

            withAnimation(.easeOut) {
                if(offsetPredicted < -0.5 && offset > -0.5) {
                    self.currentFloatIndex = CGFloat(min(max(Int(newIndex.rounded() + 1), 0), self.pageCount - 1))
                } else if (offsetPredicted > 0.5 && offset < 0.5) {
                    self.currentFloatIndex = CGFloat(min(max(Int(newIndex.rounded() - 1), 0), self.pageCount - 1))
                } else {
                    self.currentFloatIndex = CGFloat(min(max(Int(newIndex.rounded()), 0), self.pageCount - 1))
                }
            }
        })
    }
    
    var body: some View {
        ViewHolder
        .onLoad {
            currentFloatIndex = CGFloat(currentIndex)
        }
        .onChange(of: currentIndex, perform: { value in
            print("index changed")
            
            // this is probably animated twice, if the tab change occurs because of the drag gesture
            withAnimation(.easeOut) {
                currentFloatIndex = CGFloat(value)
            }
        })
        
        .onReceive(autoScrollTimer, perform: { output in
            if autoScrollSeconds <= 0 {
                return
            }
            
            autoScrollCountupSeconds += 0.03
            if self.isDragging
            {
                autoScrollCountupSeconds = 0
                return
            }
            
            if autoScrollSeconds < autoScrollCountupSeconds
            {
                autoScrollCountupSeconds = 0
                
                var __index = currentIndex
                if __index + 1 >= pageCount
                {
                    __index = 0
                }
                else
                {
                    __index += 1
                }
                
                print("\(currentIndex), \(pageCount)")
                self.currentFloatIndex = CGFloat(currentIndex)
                
                withAnimation(.easeInOut) {
                    self.currentFloatIndex = CGFloat(__index)
                }
                
                
            }
        })
        
        .onAppear {
            
        }
    }
}



