import Astryx
import AstryxNative
import SwiftUI

private let photo = "https://avatars.githubusercontent.com/u/69631?s=256&v=4"

struct AvatarStatusDotScreen: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      CaptureRow(title: "Variants: success (filled), neutral (ring), error (minus) on lg") {
        Flow(spacing: 16) {
          Avatar("Ada Lovelace", size: .lg) { AvatarStatusDot(variant: .success, label: "Online") }
          Avatar("Grace Hopper", size: .lg) { AvatarStatusDot(variant: .neutral, label: "Away") }
          Avatar("Alan Turing", size: .lg) { AvatarStatusDot(variant: .error, label: "Busy") }
        }
      }
      CaptureRow(title: "Tiers: sm and md (small), lg (medium), xl (large)") {
        Flow(spacing: 16) {
          Avatar("Ada Lovelace", size: .sm) { AvatarStatusDot(variant: .error) }
          Avatar("Ada Lovelace", size: .md) { AvatarStatusDot(variant: .neutral) }
          Avatar("Ada Lovelace", size: .lg) { AvatarStatusDot(variant: .error) }
          Avatar("Ada Lovelace", src: photo, size: .xl) { AvatarStatusDot(variant: .success) }
        }
      }
      CaptureRow(title: "Shapes: circle, rounded, square") {
        Flow(spacing: 16) {
          ForEach(AvatarShape.allCases, id: \.self) { shape in
            Avatar("Ada Lovelace", size: .lg, shape: shape) { AvatarStatusDot(variant: .neutral) }
          }
        }
      }
      CaptureRow(title: "Right to left") {
        Flow(spacing: 16) {
          Avatar("Ada Lovelace", size: .lg) { AvatarStatusDot(variant: .success) }
          Avatar("Ada Lovelace", size: .lg, shape: .square) { AvatarStatusDot(variant: .error) }
        }
        .environment(\.layoutDirection, .rightToLeft)
      }
      CaptureRow(title: "Themes: neutral and butter") {
        Flow(spacing: 16) {
          Avatar("Ada Lovelace", size: .lg) { AvatarStatusDot(variant: .success) }.astryxTheme(.neutral)
          Avatar("Ada Lovelace", size: .lg) { AvatarStatusDot(variant: .error) }.astryxTheme(.butter)
        }
      }
    }
  }
}
