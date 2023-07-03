//
//  View+SafeAreaInset.swift
//  hkstp oneapp testing
//
//  Created by Leung Yu Wing on 15/2/2022.
//

import Foundation
import SwiftUI

struct TopSafeAreaInsetKey: EnvironmentKey {
  static var defaultValue: CGFloat = 0
}

extension EnvironmentValues {
  var topSafeAreaInset: CGFloat {
    get { self[TopSafeAreaInsetKey.self] }
    set { self[TopSafeAreaInsetKey.self] = newValue }
  }
}

struct BottomSafeAreaInsetKey: EnvironmentKey {
  static var defaultValue: CGFloat = 0
}

extension EnvironmentValues {
  var bottomSafeAreaInset: CGFloat {
    get { self[BottomSafeAreaInsetKey.self] }
    set { self[BottomSafeAreaInsetKey.self] = newValue }
  }
}



extension View {
  func readHeight(onChange: @escaping (CGFloat) -> Void) -> some View {
    background(
      GeometryReader { geometryProxy in
        Spacer()
          .preference(
            key: HeightPreferenceKey.self,
            value: geometryProxy.size.height
          )
      }
    )
    .onPreferenceChange(HeightPreferenceKey.self, perform: onChange)
  }
}

private struct HeightPreferenceKey: PreferenceKey {
  static var defaultValue: CGFloat = .zero
  static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {}
}





struct TopInsetViewModifier<OverlayContent: View>: ViewModifier {
    @Environment(\.topSafeAreaInset) var ancestorTopSafeAreaInset: CGFloat
  var overlayContent: OverlayContent
  @State var overlayContentHeight: CGFloat = 0

  func body(content: Self.Content) -> some View {
    content
          .environment(\.topSafeAreaInset, overlayContentHeight + ancestorTopSafeAreaInset) // 👈🏻 1
      .overlay(
        overlayContent
          .readHeight {
            overlayContentHeight = $0
          }
          .padding(.top, ancestorTopSafeAreaInset) // 👈🏻 2
        ,
        alignment: .top
      )
  }
}


struct BottomInsetViewModifier<OverlayContent: View>: ViewModifier {
  @Environment(\.bottomSafeAreaInset) var ancestorBottomSafeAreaInset: CGFloat
  var overlayContent: OverlayContent
  @State var overlayContentHeight: CGFloat = 0

  func body(content: Self.Content) -> some View {
    content
      .environment(\.bottomSafeAreaInset, overlayContentHeight + ancestorBottomSafeAreaInset) // 👈🏻 1
      .overlay(
        overlayContent
          .readHeight {
            overlayContentHeight = $0
          }
          .padding(.bottom, ancestorBottomSafeAreaInset) // 👈🏻 2
        ,
        alignment: .bottom
      )
  }
}

@available(iOS, introduced: 13, deprecated: 15, message: "Use .safeAreaInset() directly") // 👈🏻 2
extension View {
    @ViewBuilder
    func topSafeAreaInset<OverlayContent: View>(_ overlayContent: OverlayContent) -> some View {
      if #available(iOS 15.0, *) {
        self.safeAreaInset(edge: .top, spacing: 0, content: { overlayContent }) // 👈🏻 1
      } else {
        self.modifier(TopInsetViewModifier(overlayContent: overlayContent))
      }
    }
    @ViewBuilder
    func bottomSafeAreaInset<OverlayContent: View>(_ overlayContent: OverlayContent) -> some View {
      if #available(iOS 15.0, *) {
        self.safeAreaInset(edge: .bottom, spacing: 0, content: { overlayContent }) // 👈🏻 1
      } else {
        self.modifier(BottomInsetViewModifier(overlayContent: overlayContent))
      }
    }
}

