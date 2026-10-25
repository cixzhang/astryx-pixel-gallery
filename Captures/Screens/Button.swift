import Astryx
import AstryxNative
import SwiftUI

struct ButtonScreen: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      CaptureRow(title: "Variants: primary secondary ghost destructive") {
        Flow(spacing: 12) {
          ForEach(ButtonVariant.allCases, id: \.self) { variant in
            Button(label: variant.rawValue, variant: variant) {}
          }
        }
      }
      CaptureRow(title: "Sizes: sm md lg") {
        Flow(spacing: 12) {
          ForEach(ButtonSize.allCases, id: \.self) { size in
            Button(label: size.rawValue, variant: .primary, size: size) {}
          }
        }
      }
      CaptureRow(title: "Loading (undimmed); disabled (dimmed)") {
        Flow(spacing: 12) {
          Button(label: "Saving", variant: .primary, isLoading: true) {}
          Button(label: "Disabled", variant: .primary, isDisabled: true) {}
        }
      }
      CaptureRow(title: "Width fill") {
        Button(label: "Continue", variant: .primary, width: .fill) {}
      }
      CaptureRow(title: "href: link; loading link; disabled link (a button)") {
        Flow(spacing: 12) {
          Button(label: "Docs", href: "https://example.com")
          Button(label: "Docs", isLoading: true, href: "https://example.com")
          Button(label: "Docs", isDisabled: true, href: "https://example.com")
        }
      }
      CaptureRow(title: "Elevation: none low med high") {
        Flow(spacing: 16) {
          ForEach(ButtonElevation.allCases, id: \.self) { elevation in
            Button(label: elevation.rawValue, elevation: elevation) {}
          }
        }
        .padding(.vertical, 6)
      }
      CaptureRow(title: "Two themes: neutral, butter") {
        Flow(spacing: 12) {
          Button(label: "Neutral", variant: .primary) {}.astryxTheme(.neutral)
          Button(label: "Butter", variant: .primary) {}.astryxTheme(.butter)
        }
      }
    }
  }
}
