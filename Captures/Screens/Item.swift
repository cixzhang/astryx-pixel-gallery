import Astryx
import AstryxNative
import SwiftUI

private let photo = "https://avatars.githubusercontent.com/u/69631?s=256&v=4"

struct ItemScreen: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      CaptureRow(title: "People: Avatar start, chevron end, button rows") {
        VStack(spacing: 0) {
          Item("Ada Lovelace", description: "Mathematician", onClick: {}) {
            Avatar("Ada Lovelace", src: photo)
          } endContent: {
            Icon(.chevronRight, color: .secondary)
          }
          Item("Grace Hopper", description: "Rear admiral", isSelected: true, onClick: {}) {
            Avatar("Grace Hopper")
          } endContent: {
            Icon(.chevronRight, color: .secondary)
          }
          Item("Alan Turing", description: "Away", isDisabled: true, onClick: {}) {
            Avatar("Alan Turing")
          } endContent: {
            Icon(.chevronRight, color: .secondary)
          }
        }
      }
      CaptureRow(title: "Settings: Icon start, value end, highlighted") {
        VStack(spacing: 0) {
          Item("Search", isHighlighted: true) { Icon(.search, color: .secondary) } endContent: {
            SwiftUI.Text("On").foregroundStyle(.secondary)
          }
          Item("Calendar", href: "https://example.com/calendar") { Icon(.calendar, color: .secondary) }
          Item("Upload") { Icon(.upload, color: .secondary) }
        }
      }
      CaptureRow(title: "Density: compact, balanced, spacious") {
        VStack(spacing: 0) {
          Item("Compact", density: .compact) { Icon(.check, color: .success) }
          Item("Balanced") { Icon(.check, color: .success) }
          Item("Spacious", density: .spacious) { Icon(.check, color: .success) }
        }
      }
      CaptureRow(title: "Align with a two-line description: center, start, first line") {
        VStack(spacing: 0) {
          ForEach([ItemAlign.center, .start, .firstLine], id: \.self) { align in
            Item(
              "Align \(align.rawValue)",
              description: "A description long enough to take two lines in this row",
              align: align, descriptionLines: 2
            ) {
              Avatar("Ada Lovelace", size: .sm)
            }
          }
        }
      }
      CaptureRow(title: "Layout inline, and a label limited to two lines") {
        VStack(spacing: 0) {
          Item("Build", description: "passed 2 minutes ago", layout: .inline) { Icon(.success, color: .success) }
          Item("A label long enough that it needs two lines before it truncates, and then some more", labelLines: 2)
        }
      }
      CaptureRow(title: "Themes: neutral and butter, selected") {
        VStack(spacing: 0) {
          Item("Neutral", isSelected: true) { Icon(.info, color: .accent) }.astryxTheme(.neutral)
          Item("Butter", isSelected: true) { Icon(.info, color: .accent) }.astryxTheme(.butter)
        }
      }
    }
  }
}
