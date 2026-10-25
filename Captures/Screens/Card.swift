import Astryx
import AstryxNative
import SwiftUI

struct CardScreen: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      CaptureRow(title: "Padding: 0.5, 2, 4 (default), 8") {
        Flow(spacing: 12) {
          ForEach([CardPadding.v0_5, .v2, .v4, .v8], id: \.self) { padding in
            Card(padding: padding) { Text("\(padding.rawValue, specifier: "%g")") }.fixedSize()
          }
        }
      }
      CaptureRow(title: "Variants: default muted transparent blue green orange purple") {
        Flow(spacing: 12) {
          ForEach([CardVariant.default, .muted, .transparent, .blue, .green, .orange, .purple], id: \.self) { variant in
            Card(variant: variant) { Text(variant.rawValue, type: .label) }.fixedSize()
          }
        }
      }
      CaptureRow(title: "Elevation: none low med high") {
        Flow(spacing: 20) {
          ForEach(CardElevation.allCases, id: \.self) { elevation in
            Card(elevation: elevation) { Text(elevation.rawValue, type: .label) }.fixedSize()
          }
        }
        .padding(.vertical, 8)
      }
      CaptureRow(title: "Content: heading and supporting text") {
        Card {
          Heading("Sign in", level: .v3)
          Text("Enter your credentials to continue", type: .supporting)
        }
      }
      CaptureRow(title: "Two themes, elevation high: neutral (inset ring), butter") {
        Flow(spacing: 20) {
          Card(elevation: .high) { Text("Neutral") }.fixedSize().astryxTheme(.neutral)
          Card(elevation: .high) { Text("Butter") }.fixedSize().astryxTheme(.butter)
        }
        .padding(.vertical, 8)
      }
    }
  }
}
