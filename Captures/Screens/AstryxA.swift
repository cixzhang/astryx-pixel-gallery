import Astryx
import SwiftUI

/// #8290 options: astryx controls under Core (top half) and Neutral (bottom half).
struct AstryxAScreen: View {
  var body: some View {
    VStack(spacing: 0) {
      section("Core (default)", .default)
      section("Neutral", .neutral)
    }
  }

  func section(_ title: String, _ theme: Theme) -> some View {
    VStack(alignment: .leading, spacing: 10) {
      SwiftUI.Text(title).font(.caption).foregroundStyle(.secondary)
      Astryx.Button(label: "Primary", variant: .primary) {}
      Astryx.Button(label: "Secondary") {}
      Astryx.Text("Body text in the theme's color")
      Astryx.Card {
        Astryx.Text("Text inside a card")
        Astryx.Button(label: "Action", variant: .primary) {}
      }
      .frame(width: 300)
    }
    .astryxTheme(theme)
    .padding(16)
    .frame(maxWidth: .infinity, minHeight: 380, maxHeight: 380, alignment: .topLeading)
  }
}
