import Astryx
import AstryxNative
import SwiftUI

struct TextHeadingScreen: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      CaptureRow(title: "Text types: body large label supporting code") {
        VStack(alignment: .leading, spacing: 6) {
          Text("Body text", type: .body)
          Text("Large text", type: .large)
          Text("Label text", type: .label)
          Text("Supporting text", type: .supporting)
          Text("let total = 42", type: .code)
        }
      }
      CaptureRow(title: "Display types: display-1 display-2 display-3 (heading family)") {
        VStack(alignment: .leading, spacing: 2) {
          Text("$1.2M", type: .display1)
          Text("$1.2M", type: .display2)
          Text("$1.2M", type: .display3)
        }
      }
      CaptureRow(title: "Colors: primary secondary disabled placeholder accent") {
        Flow(spacing: 12) {
          ForEach(TextColor.allCases.filter { $0 != .inherit }, id: \.self) { color in
            Text(color.rawValue, color: color)
          }
        }
      }
      CaptureRow(title: "Weights; strikethrough; tabular numbers") {
        VStack(alignment: .leading, spacing: 4) {
          Flow(spacing: 12) {
            ForEach(TextWeight.allCases, id: \.self) { weight in Text(weight.rawValue, weight: weight) }
          }
          Text("Was $40", hasStrikethrough: true)
          Text("1111.11", hasTabularNumbers: true)
          Text("8888.88", hasTabularNumbers: true)
        }
      }
      CaptureRow(title: "maxLines 2, justify end") {
        Text("A long description that keeps going well past two lines so the clamp shows an ellipsis at the end of the second line.", maxLines: 2, justify: .end)
          .frame(width: 260, alignment: .leading)
      }
      CaptureRow(title: "Headings 1–6") {
        VStack(alignment: .leading, spacing: 2) {
          Heading("Heading 1", level: .v1)
          Heading("Heading 2", level: .v2)
          Heading("Heading 3", level: .v3)
          Heading("Heading 4", level: .v4)
          Heading("Heading 5", level: .v5)
          Heading("Heading 6", level: .v6)
        }
      }
      CaptureRow(title: "Heading: display type; justify center; color secondary") {
        VStack(alignment: .leading, spacing: 4) {
          Heading("Revenue", level: .v2, type: .display2)
          Heading("Centered", level: .v3, justify: .center).frame(width: 300)
          Heading("Secondary", level: .v3, color: .secondary)
        }
      }
      CaptureRow(title: "Two themes: neutral, butter") {
        VStack(alignment: .leading, spacing: 4) {
          Heading("Neutral heading", level: .v3).astryxTheme(.neutral)
          Heading("Butter heading", level: .v3).astryxTheme(.butter)
        }
      }
    }
  }
}
