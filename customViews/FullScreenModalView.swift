//
//  FullscreenModelView.swift
//  hkstp oneapp testing
//
//  Created by Leung Yu Wing on 23/3/2022.
//

import Foundation
import SwiftUI



struct FullScreenModalView<Content: View>: View {
//    @Environment(\.presentationMode) var presentationMode
    @Environment(\.fullScreenModalState) var modalState: FullScreenModalState

    let content: Content
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    @ViewBuilder
    var body: some View {
        ZStack {
            self.content
        }
    }
    
    
//    var body: some View {
//        ZStack {
//            self.content
//            HStack(alignment: .top, spacing: 10) {
//                Spacer()
//                VStack(alignment: .leading, spacing: 10) {
//                    Spacer().frame(height: 44)
//                    Button("Close") {
//        //                presentationMode.wrappedValue.dismiss()
//                        modalState.close.send()
//                    }
//                    .padding()
//                    .foregroundColor(.white)
//                    Spacer()
//                }
//            }
//        }
//    }
}



struct FullScreenModalDialogViewButton : Identifiable {
    var id = UUID().uuidString
    var text: String
    var style: UIAlertAction.Style
    var isDisabled: Bool? = false
    var handler: (Int) -> Void
}



struct FullScreenModalDialogView: View {
//    @Environment(\.presentationMode) var presentationMode
    @Environment(\.fullScreenModalState) var modalState: FullScreenModalState

    var icon: String? = nil
    var title: String
    var message: String
    var messageRich: String? = nil
    var buttons: [FullScreenModalDialogViewButton]
    
    init(
        icon: String? = nil,
        title: String,
        message: String,
        messageRich: String? = nil,
        buttons: [FullScreenModalDialogViewButton]
//        @ViewBuilder content: () -> Content
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.messageRich = messageRich
        self.buttons = buttons
    }

    @ViewBuilder
    var body: some View {
        FullScreenModalView {
            ZStack {
                Rectangle()
                    .fill(
                        Color(UIColor.palette_bgBlack2())
                            .opacity(0.75)
                        )
                
                ZStack {
                    
                    VStack {
                        Spacer()
                        
                        ZStack {

                            VStack(spacing: 0) {

                                VStack(spacing: 0) {
                                    
                                    if let icon = icon {
                                        Icon(icon: icon, iconSize: 160)
                                        TP1PageSpacer(h: 8)
                                            .debugFrameSize()
                                    }

                                    if title.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                                        Text(title)
                                            .modifier(TP1AppTextViewModifier(viewElementStyles: .shared, typography: .en_header_h4_bold, fontColor: .body))
                                            .modifier(TP1AppTextViewLineModifier(viewElementStyles: .shared, numberOfLines: nil, textAlign: .leading))
                                            .modifier(TP1AppLayoutModifier(viewElementStyles: .shared, fillType: .horizontal_fill_leading))
                                            .debugFrameSize()
                                        TP1PageSpacer(h: 8)
                                            .debugFrameSize()
                                    }

                                    if let messageRich = messageRich {
                                        GenericFlexibleHeightWebView(
                                            htmlContent: messageRich,
                                            htmlContentHeightExtra: 0
                                        )
                                            .debugFrameSizeHighlighted()
                                    } else {
                                        Text(message.trimmingCharacters(in: .whitespacesAndNewlines))
                                            .modifier(TP1AppTextViewModifier(viewElementStyles: .shared, typography: .en_body_body1_reg, fontColor: .notes))
                                            .modifier(TP1AppTextViewLineModifier(viewElementStyles: .shared, numberOfLines: nil, textAlign: .leading))
                                            .modifier(TP1AppLayoutModifier(viewElementStyles: .shared, fillType: .horizontal_fill_leading))
                                            .debugFrameSizeHighlighted()
                                    }

                                    TP1PageSpacer(h: 24)
                                        .debugFrameSize()

                                    VStack(alignment: .center, spacing: 16) {

                                        ForEach(0 ..< buttons.count, id: \.self) { index in
                                            
                                            let button = buttons[index]
                                            
                                            TP1ButtonCTA(
                                                action: {
                                                    modalState.close.send()
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                                                        button.handler(index)
                                                    }
                                                },
                                                text: button.text,
                                                type: button.style == .default ? .primary : .secondary,
                                                grayed: false,
                                                disabled: false,
                                                layoutModifier: .init(viewElementStyles: .shared, fillType: .horizontal_fill_center))

                                        }
                                    }

                                    
                                }
                                
                                .padding(.horizontal, 20)
                                .padding(.vertical, 20)

                            }
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(
                                        TP1ViewElementStyles.shared.activeColorTheme.color_content_background
                                    )
//                                    .shadow(color: Color(UIColor.palette_bgBlack()), radius: 10, x: 0, y: 1)
                            )
                            .debugFrameSize()
                        }
                        .debugFrameSize()

                        Spacer()
                            .debugFrameSize()


                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}


struct __DEMO_FullScreenModalView_Previews: PreviewProvider {
    static var previews: some View {
        FullScreenModalDialogView(
                title: "cancel_without_saving".i18n(),
                message: "Are you sure you want to leave without saving your changes?",
                buttons: [
                    FullScreenModalDialogViewButton(text: "yes".i18n(), style: .default, isDisabled: false, handler: { int in
                        
                    }),
                    FullScreenModalDialogViewButton(text: "no".i18n(), style: .cancel, isDisabled: false, handler: { int in
                        
                    }),
                ]
                )
        
    }
}
