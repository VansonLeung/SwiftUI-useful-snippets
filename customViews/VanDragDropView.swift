//
//  VanDragDropView.swift
//  hkstp oneapp testing
//
//  Created by van on 14/7/2022.
//

import Foundation
import SwiftUI

class VanDragDropViewSwapObserver: ObservableObject {
    public static var shared = VanDragDropViewSwapObserver()

    @Published var isSwap: Bool = false
    @Published var isApplySwap: Bool = false
    @Published var onApplySwap: Bool = false
    @Published var swapUuidA: String = ""
    @Published var swapUuidARect: CGRect = .zero
    @Published var swapUuidB: String = ""
    @Published var swapUuidBRect: CGRect = .zero
    
    func requestSwap(
        uuidA: String,
        uuidARect: CGRect,
        uuidB: String,
        uuidBRect: CGRect)
    {
        isSwap = true
        self.swapUuidA = uuidA
        self.swapUuidARect = uuidARect
        self.swapUuidB = uuidB
        self.swapUuidBRect = uuidBRect
    }
    
    func cancelSwap()
    {
        isSwap = false
        self.swapUuidA = ""
        self.swapUuidB = ""
        self.swapUuidARect = .zero
        self.swapUuidBRect = .zero
    }
    
    func applySwap()
    {
        if isSwap
        {
            isApplySwap = true
        }
    }
    
    func onSwapEnded()
    {
        isApplySwap = false
        self.cancelSwap()
        onApplySwap = true
        DispatchQueue.main.async {
            self.onApplySwap = false
        }
    }
}

class VanDragDropViewObserver: ObservableObject {
    public static var shared = VanDragDropViewObserver()
    @Published var dragLocation: CGPoint = .zero
    @Published var isDragging: Bool = false
    @Published var dragUuid: String = ""
    var anyView: AnyView? = nil
    
    var uuidDropLocationMap : [String: CGRect] = [:]

    func setDragging(boo: Bool, dragLocation: CGPoint, anyView: AnyView?, dragUuid: String)
    {
        self.isDragging = boo
        self.dragLocation = dragLocation
        self.anyView = anyView
        self.dragUuid = dragUuid

        self.onDragging()
    }
    
    func endDragging()
    {
        VanDragDropViewSwapObserver.shared.applySwap()

        self.isDragging = false
        self.dragLocation = .zero
        self.anyView = nil
        self.dragUuid = ""
    }
    
    func putDropLocation(dropUuid: String, locationRect: CGRect)
    {
        uuidDropLocationMap[dropUuid] = locationRect
    }
    
    func onDragging()
    {
        if self.isDragging
        {
            if let dragRect = uuidDropLocationMap[dragUuid]
            {
                let dragUuidKv = [dragUuid: dragRect]

                for dropUuidKv in uuidDropLocationMap
                {
                    let dropUuid = dropUuidKv.key
                    let dropLocation = dropUuidKv.value
                    
                    if dropUuid != dragUuid
                    {
                        if dropLocation.contains(dragLocation)
                        {
                            VanDragDropViewSwapObserver.shared.requestSwap(
                                uuidA: dragUuid, uuidARect: dragRect,
                                uuidB: dropUuid, uuidBRect: dropLocation
                            )
                            return
                        }
                    }
                }
            }
        }
        
        VanDragDropViewSwapObserver.shared.cancelSwap()
        return
    }
}

struct VanDragView<Content: View, DraggingContent: View>: View {
    var isDebug : Bool? = false
    var uuid = UUID().uuidString
    @State var isDragging: Bool = false
    
    @GestureState var offset : CGPoint = .zero
    
    var content: () -> Content
    var draggingContent: () -> DraggingContent
    var body: some View {
        ZStack {
            content()
        }
        .opacity(isDragging ? 0.2 : 1.0)
        .highPriorityGesture(DragGesture(
            minimumDistance: 20, coordinateSpace: .global)
            .updating(self.$offset, body: { value, state, transaction in
                if state.x == 0 && state.y == 0
                {
                    if value.translation.height <= -10
                        || value.translation.height >= 10
                    {
                        print("A")
                        DispatchQueue.main.async {
                            self.isDragging = false
                            VanDragDropViewObserver.shared.endDragging()
                        }
                    }
                    else
                    {
                        print("B")
                        state = CGPoint(x: value.translation.width, y: value.translation.height)
                    }
                }
                else
                {
                    print("C")
                    state = CGPoint(x: value.translation.width, y: value.translation.height)
                }
            })
            .onChanged({ value in
                self.isDragging = true
                VanDragDropViewObserver.shared.setDragging(
                    boo: true,
                    dragLocation: value.location,
                    anyView: AnyView(draggingContent()),
                    dragUuid: uuid
                )
            })
            .onEnded { _ in
                self.isDragging = false
                VanDragDropViewObserver.shared.endDragging()
            }
        )
//        .fixedSize()
    }
}



fileprivate struct SetAbsolutePositionViewModifier: ViewModifier {
    var rect: CGRect
    func body(content: Content) -> some View {
        content
            .position(x: rect.origin.x, y: rect.origin.y)
            .frame(width: rect.size.width, height: rect.size.height)
    }
}


struct VanDropView<Content: View>: View {
    @StateObject var swapObs = VanDragDropViewSwapObserver.shared
    var isDebug: Bool? = false
    var uuid = UUID().uuidString
    var content: () -> Content
    
    func updateDropLocation(frame: CGRect) {
        VanDragDropViewObserver.shared.putDropLocation(
            dropUuid: uuid,
            locationRect: .init(
                x: frame.origin.x,
                y: frame.origin.y,
                width: frame.size.width,
                height: frame.size.height)
        )
    }
    
    @State var c : Int = 0
    
    var body: some View {
        ZStack {
            ZStack {
                content()
                GeometryReader { geometry in
                    let frame = geometry.frame(in: CoordinateSpace.global)
                    ZStack {
                        if isDebug == true
                        {
                            Text("\(c): \(frame.origin.x) \(frame.origin.y)")
                        }
                    }
                    .onAppear {
                        updateDropLocation(frame: frame)
                    }
                    .onChange(of: geometry.frame(in: CoordinateSpace.global), perform: { newValue in
                        updateDropLocation(frame: newValue)
                    })
                    .onChange(of: swapObs.onApplySwap, perform: { newValue in
                        
                    })
                }
            }
//            .fixedSize()
        }
    }
}





struct VanDragDropWorkspaceOverlayView: View {
    @StateObject var obs = VanDragDropViewObserver.shared
    var offset: CGPoint?
    
    var body: some View {
        ZStack {
            if obs.isDragging
            {
                if let v = obs.anyView {
                    v
                        .fixedSize()
                        .position(
                            x: obs.dragLocation.x,
                            y: obs.dragLocation.y
                        )
                        .offset(
                            x: offset?.x ?? 0,
                            y: offset?.y ?? 0
                        )
                }
            }
        }
    }
}

struct VanDragView_PreviewsDemo: View {
    @StateObject var swapObs = VanDragDropViewSwapObserver.shared
    @StateObject var dragObs = VanDragDropViewObserver.shared
    
    @State var oldSorting : [String] = [
        "t1_neg_directory",
        "t1_neg_events",
        "t1_neg_innocell",
        "t1_neg_mice",
        "t1_neg_parking",
        "t1_neg_poi",
        "t1_neg_publictransport",
        "t1_neg_shuttlebus",
        "t1_neg_wifi",
    ]
    
    @State var isDebug: Bool = false

    
    
    func getSorting() -> [String] {
        if swapObs.isSwap
        {
            var newSorting = oldSorting.map { $0 }
            let sortIndexA = newSorting.firstIndex(of: swapObs.swapUuidA) ?? -1
            let sortIndexB = newSorting.firstIndex(of: swapObs.swapUuidB) ?? -1
            if sortIndexA != -1 && sortIndexB != -1
            {
                newSorting.swapAt(sortIndexA, sortIndexB)
            }
            return newSorting
        }
        return oldSorting
    }
    
    
    
    var body: some View {
        
        ZStack {
            
            if isDebug {
                VStack {
                    Spacer()
                    ForEach(Array(dragObs.uuidDropLocationMap.keys), id: \.self) { i in
                        Text("\(i): \(dragObs.uuidDropLocationMap[i]?.origin.x ?? -1), \(dragObs.uuidDropLocationMap[i]?.origin.y ?? -1)")
                    }
                    Text("swapObs \nisSwap: \(swapObs.isSwap ? "T" : "F") , isApplySwap \(swapObs.isApplySwap ? "T" : "F") , onApplySwap \(swapObs.onApplySwap ? "T" : "F")")
                    Text("swapObs \n\(swapObs.swapUuidA) \n\(swapObs.swapUuidARect.origin.dictionaryRepresentation) \n\(swapObs.swapUuidB) \n\(swapObs.swapUuidBRect.origin.dictionaryRepresentation)")
                }
            }
            
            VStack {

                LazyVGrid(columns: [
                    GridItem(.flexible(minimum: 40), spacing: 8, alignment: .top),
                    GridItem(.flexible(minimum: 40), spacing: 8, alignment: .top),
                    GridItem(.flexible(minimum: 40), spacing: 8, alignment: .top),
                    GridItem(.flexible(minimum: 40), spacing: 8, alignment: .top),
                ], alignment: .leading, spacing: 0) {

                    ForEach(oldSorting, id: \.self) { uuid in
                        
                        VanDragView(isDebug: isDebug, uuid: uuid) {
                            VanDropView(isDebug: isDebug, uuid: uuid) {
                                QuickLinkButton(item: .init(
                                    id: uuid,
                                    action: {
                                        
                                    },
                                    icon: uuid,
                                    text: uuid,
                                    icon_secondary: uuid,
                                    is_secondary: true
                                    )
                                )
                                .padding(.bottom, 16)
                            }
                        } draggingContent: {
                            QuickLinkButton(item: .init(
                                id: uuid,
                                action: {
                                    
                                },
                                icon: uuid,
                                text: uuid,
                                icon_secondary: uuid,
                                is_secondary: true
                                )
                            )
                            .shadow(color: .black.opacity(0.5), radius: 3, x: 0, y: 4)
                            .padding(.bottom, 16)
                            .opacity(0.75)
                        }

                        
                    }

                }

                .padding(.horizontal, 20)
                
                
                Spacer()
            }

            VStack {
                Spacer()
            }
            
            VanDragDropWorkspaceOverlayView()
                .onChange(of: swapObs.isApplySwap) { newValue in
                    if newValue == true
                    {
                        withAnimation(.default) {
                            oldSorting = getSorting()
                        }
                        swapObs.onSwapEnded()
                    }
                }
        }

    }
}

struct VanDragView_Previews: PreviewProvider {
    static var previews: some View {
        VanDragView_PreviewsDemo()
    }
}
