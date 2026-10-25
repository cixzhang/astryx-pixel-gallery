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
      CaptureRow(title: "Variants: all 13") {
        Flow(spacing: 12) {
          ForEach(CardVariant.allCases, id: \.self) { variant in
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
      CaptureRow(title: "Wire tree: a node this package cannot draw renders in place") {
        AstryxNodeView(try! JSONDecoder().decode(AstryxNode.self, from: Data("""
          {"component":"Card","key":"c","props":{"children":[
            {"component":"Heading","key":"h","props":{"children":"Wire card","level":3}},
            {"component":"Chart","key":"x","props":{}},
            {"component":"Text","key":"t","props":{"children":"Siblings still render"}}]}}
          """.utf8))) { _ in }
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
