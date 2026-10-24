// Copyright (c) Meta Platforms, Inc. and affiliates.

import SwiftUI

/// A card: one independent item on the theme's card ground, with a hairline
/// border and the container radius.
public struct AstryxCard<Content: View>: View {
  let padding: Int?
  let content: Content
  @Environment(\.astryx) private var astryx

  /// - Parameter padding: a step on the spacing ladder, as core's `padding`.
  ///   SPIKE (H4): omitted, the card takes the theme's card padding.
  public init(padding: Int? = nil, @ViewBuilder content: () -> Content) {
    self.padding = padding
    self.content = content()
  }

  public var body: some View {
    // SPIKE (H4, H5): shape, border, and default padding from the theme.
    let shape = astryx.surfaceShape("card", radius: "radius-container", 12)
    content
      .padding(padding.map { astryx.space($0) } ?? astryx.overrideSize("card", "padding", token: "spacing-4", 16))
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(shape.fill(astryx.color("color-background-card")))
      .overlay(astryx.surfaceBorder("card", radius: "radius-container", 12, color: "color-border"))
  }
}
