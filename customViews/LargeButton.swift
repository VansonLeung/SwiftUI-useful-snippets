import Foundation
import SwiftUI

struct LargeButtonStyle: ButtonStyle {
    
    let backgroundColor: Color
    let foregroundColor: Color
    let isDisabled: Binding<Bool>
    
    func makeBody(configuration: Self.Configuration) -> some View {
        let currentForegroundColor = isDisabled.wrappedValue || configuration.isPressed ? foregroundColor.opacity(0.3) : foregroundColor
        return configuration.label
//            .padding(EdgeInsets(top: 6, leading: 6, bottom: 6, trailing: 6))
            .buttonStyle(BorderlessButtonStyle())
            .padding()
            .foregroundColor(currentForegroundColor)
            .background(isDisabled.wrappedValue || configuration.isPressed ? backgroundColor.opacity(0.3) : backgroundColor)
            // This is the key part, we are using both an overlay as well as cornerRadius
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(currentForegroundColor, lineWidth: 1)
        )
//            .padding([.top, .bottom], 5)
            .font(Font.system(size: 19, weight: .semibold))
    }
}

struct LargeButton: View {
    
    private let buttonHorizontalMargins: CGFloat = 0
    
    var backgroundColor: Color
    var foregroundColor: Color
    
    private let title: String
    private let action: () -> Void
    
    // It would be nice to make this into a binding.
    private let disabled: Binding<Bool>
    private let loading: Binding<Bool>

    init(title: String,
         disabled: Binding<Bool> = .constant(false),
         loading: Binding<Bool> = .constant(false),
         backgroundColor: Color = Color.green,
         foregroundColor: Color = Color.white,
         action: @escaping () -> Void) {
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.title = title
        self.action = action
        self.disabled = disabled
        self.loading = loading
    }
    
    func _renderButton() {
        
    }
    
    var body: some View {
        HStack {
            Spacer(minLength: buttonHorizontalMargins)
            Button(action:self.action) {
                if self.loading.wrappedValue {
                    ActivityIndicator(isAnimating: .constant(true), style: .large)
                       .frame(maxWidth:.infinity)
                } else {
                    Text(self.title)
                        .frame(maxWidth:.infinity)
                }
            }
            .buttonStyle(LargeButtonStyle(backgroundColor: backgroundColor,
                                          foregroundColor: foregroundColor,
                                          isDisabled: disabled))
            .disabled(self.disabled.wrappedValue)
            Spacer(minLength: buttonHorizontalMargins)
        }
        .frame(maxWidth:.infinity)
    }
}


struct NavigationLinkLargeButton<Content: View>: View {
    
    private let buttonHorizontalMargins: CGFloat = 10
    
    var backgroundColor: Color
    var foregroundColor: Color
    
    private let title: String
    private let destination: Content

    // It would be nice to make this into a binding.
    private let disabled: Binding<Bool>
    
    @State var isShow: Bool = false
    
    init(title: String,
         disabled: Binding<Bool> = .constant(false),
         backgroundColor: Color = Color.green,
         foregroundColor: Color = Color.white,
         destination: Content) {
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.title = title
        self.destination = destination
        self.disabled = disabled
    }
    
    func _renderButton() {
        
    }
    
    var body: some View {
        ZStack {
            NavigationLink(isActive: $isShow) {
                destination
            } label: {
                EmptyView()
            }
            .opacity(0)
            
            HStack {
                Spacer(minLength: buttonHorizontalMargins)
                Button {
                    isShow = true
                } label: {
                    Text(self.title)
                        .frame(maxWidth:.infinity)
                }
                .buttonStyle(LargeButtonStyle(backgroundColor: backgroundColor,
                                              foregroundColor: foregroundColor,
                                              isDisabled: disabled))
                .disabled(self.disabled.wrappedValue)
                Spacer(minLength: buttonHorizontalMargins)
            }
        }
        .frame(maxWidth:.infinity)
    }
}
