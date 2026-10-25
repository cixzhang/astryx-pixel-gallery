import Astryx
import SwiftUI

/// Stock SwiftUI controls inside an Astryx theme: which color their labels take.
struct StockControlsScreen: View {
  @State private var on = true
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      ForEach([("default", Theme.default), ("butter", Theme.butter), ("neutral", Theme.neutral)], id: \.0) { name, theme in
        CaptureRow(title: "Theme \(name): Link · borderless Button · bordered Button · Toggle · plain text") {
          VStack(alignment: .leading, spacing: 8) {
            SwiftUI.Link("Stock link", destination: URL(string: "https://example.com")!)
            SwiftUI.Button("Borderless button") {}.buttonStyle(.borderless)
            SwiftUI.Button("Bordered prominent") {}.buttonStyle(.borderedProminent)
            Toggle("Toggle", isOn: $on).frame(width: 200)
            SwiftUI.Text("Plain text")
          }
          .astryxTheme(theme)
        }
      }
      CaptureRow(title: "No theme (system)") {
        VStack(alignment: .leading, spacing: 8) {
          SwiftUI.Link("Stock link", destination: URL(string: "https://example.com")!)
          SwiftUI.Button("Borderless button") {}.buttonStyle(.borderless)
        }
      }
    }
  }
}
