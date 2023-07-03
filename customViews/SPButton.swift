import SwiftUI

struct SPButton<Content: View>: View {
    
    let action: () -> Void
    let label: () -> Content

    @State var opacity : CGFloat = 1.0
    @State var isExpired : Bool = false
    @State var animDuration : CGFloat = 0

    init(action: @escaping () -> Void, @ViewBuilder label: @escaping () -> Content) {
        self.action = action
        self.label = label
    }
    
    init(_ title: String, action: @escaping () -> Void) where Content == Text {
        
        self.init(action: action, label: {
            Text(title)
        })
    }

    var body: some View {
        label()
            .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
            .opacity(opacity)
            .gesture(
                DragGesture(minimumDistance: 0.0)
                    .onChanged { state in
                        if !isExpired {
                            if abs(state.location.x - state.startLocation.x) > 100
                                ||
                                abs(state.location.y - state.startLocation.y) > 100
                            {
                                isExpired = true
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    opacity = 1.0
                                }
                            }
                            else
                            {
                                opacity = 0.1
                            }
                        }
                    }
                    .onEnded { state in
                        if !isExpired
                        {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                opacity = 1.0
                            }
                            action()
                        }
                        
                        isExpired = false
                    }
            )
        

    }
    
}



