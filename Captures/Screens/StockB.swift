import Astryx
import SwiftUI

/// #8290 options: stock controls under Core (top half) and Neutral (bottom half).
struct StockBScreen: View {
  var body: some View {
    VStack(spacing: 0) {
      section("Core (default)", .default)
      section("Neutral", .neutral)
    }
  }

  func section(_ title: String, _ theme: Theme) -> some View {
    VStack(alignment: .leading, spacing: 10) {
      SwiftUI.Text(title).font(.caption).foregroundStyle(.secondary)
      SwiftUI.Link("Stock link", destination: URL(string: "https://example.com")!)
      SwiftUI.Button("Borderless button") {}.buttonStyle(.borderless)
      SwiftUI.Button("Bordered button") {}.buttonStyle(.bordered)
      SwiftUI.Button("Prominent button") {}.buttonStyle(.borderedProminent)
      Toggle("Toggle", isOn: .constant(true)).frame(width: 220)
      SwiftUI.Text("Plain text")
    }
    .astryxTheme(theme)
    .padding(16)
    .frame(maxWidth: .infinity, minHeight: 380, maxHeight: 380, alignment: .topLeading)
  }
}
