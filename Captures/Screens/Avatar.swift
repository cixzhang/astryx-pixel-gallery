import Astryx
import AstryxNative
import SwiftUI

private let photo = "https://avatars.githubusercontent.com/u/69631?s=256&v=4"
private let broken = "https://invalid.invalid/missing.png"

struct AvatarScreen: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      CaptureRow(title: "Sizes: xsm sm md lg xl (initials)") {
        Flow(spacing: 12) {
          ForEach([AvatarSize.xsm, .sm, .md, .lg, .xl], id: \.self) { size in
            Avatar("Ada Lovelace", size: size)
          }
        }
      }
      CaptureRow(title: "Shapes: circle rounded square (photo, then initials)") {
        Flow(spacing: 12) {
          ForEach(AvatarShape.allCases, id: \.self) { shape in
            Avatar("Ada Lovelace", src: photo, size: .lg, shape: shape)
          }
          ForEach(AvatarShape.allCases, id: \.self) { shape in
            Avatar("Ada Lovelace", size: .lg, shape: shape)
          }
        }
      }
      CaptureRow(title: "Fallbacks: photo, broken src → fallbackSrc, broken → initials, no name → symbol") {
        Flow(spacing: 12) {
          Avatar("Ada Lovelace", src: photo, size: .lg)
          Avatar("Ada Lovelace", src: broken, fallbackSrc: photo, size: .lg)
          Avatar("Ada Lovelace", src: broken, size: .lg)
          Avatar(size: .lg)
        }
      }
      CaptureRow(title: "Initials: emoji, flag, punctuation, digits") {
        Flow(spacing: 12) {
          Avatar("😀 Ada", size: .lg)
          Avatar("🇬🇧 Ada", size: .lg)
          Avatar("Northwind Workbench (automation)", size: .lg)
          Avatar("R2 D2", size: .lg)
          Avatar("- ()", size: .lg)
        }
      }
      CaptureRow(title: "Static, link, button: drawn the same") {
        Flow(spacing: 12) {
          Avatar("Ada Lovelace", size: .md)
          Avatar("Ada Lovelace", size: .md, href: "https://example.com/ada")
          Avatar("Ada Lovelace", size: .md) {}
        }
      }
      CaptureRow(title: "In a row beside text") {
        HStack(spacing: 10) {
          Avatar("Grace Hopper", src: photo, size: .md)
          VStack(alignment: .leading) {
            SwiftUI.Text("Grace Hopper").font(.body)
            SwiftUI.Text("Rear admiral").font(.subheadline).foregroundStyle(.secondary)
          }
        }
      }
      CaptureRow(title: "Themes: default, neutral, butter") {
        Flow(spacing: 12) {
          Avatar("Ada Lovelace", size: .lg)
          Avatar("Ada Lovelace", size: .lg).astryxTheme(.neutral)
          Avatar("Ada Lovelace", size: .lg).astryxTheme(.butter)
        }
      }
    }
  }
}
