// SPIKE: the native side of the web comparison. Same content as
// native/web/compare.tsx, drawn with swift-ios-1's components.

import AstryxCore
import AstryxTemplates
import SwiftUI

public struct ComponentsScreen: View {
  @State private var email = ""
  @Environment(\.astryx) private var astryx

  public init() {}

  public var body: some View {
    VStack(alignment: .leading, spacing: astryx.space(4)) {
      AstryxHeading("Components", level: 2)
      VStack(alignment: .leading, spacing: astryx.space(1)) {
        AstryxText("Body text")
        AstryxText("Label", type: .label)
        AstryxText("Supporting", type: .supporting)
      }
      HStack(spacing: astryx.space(2)) {
        AstryxButton(label: "Primary", variant: .primary) {}
        AstryxButton(label: "Second") {}
      }
      HStack(spacing: astryx.space(2)) {
        AstryxButton(label: "Ghost", variant: .ghost) {}
        AstryxButton(label: "Delete", variant: .destructive) {}
      }
      AstryxCard {
        VStack(alignment: .leading, spacing: astryx.space(2)) {
          AstryxHeading("Card", level: 3)
          AstryxText("One item.")
        }
      }
      AstryxTextInput(label: "Email", value: $email, placeholder: "you@x.com")
      AstryxBanner(status: .info, title: "Saved", description: "It is live.")
      AstryxBanner(status: .error, title: "Sync failed")
    }
    .padding(astryx.space(6))
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    .background(astryx.color("color-background-body").ignoresSafeArea())
  }
}

/// Which rendering to show, from the launch arguments (`-variant`).
public enum SpikeVariant: String, CaseIterable, Sendable {
  /// The generator alone: pixel tokens into swift-ios-1 exactly as it is.
  case today
  /// Spike hooks on, but only what defineNativeTheme on main can say.
  case hooksToday
  /// Spike hooks on, with the proposed vocabulary.
  case proposed

  public var theme: AstryxTheme { self == .hooksToday ? .pixelToday : .pixel }
  public var hooks: Bool { self != .today }
}

public struct SpikeRoot: View {
  let view: String
  let variant: SpikeVariant

  public init(view: String, variant: SpikeVariant) {
    self.view = view
    self.variant = variant
  }

  public var body: some View {
    Group {
      if view == "login" {
        LoginTemplate()
      } else {
        ComponentsScreen()
      }
    }
    .astryxTheme(variant.theme)
    .environment(\.astryxSpikeHooks, variant.hooks)
  }
}
