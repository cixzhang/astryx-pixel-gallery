import Astryx
import SwiftUI

struct IconScreen: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      CaptureRow(title: "Sizes: xsm sm md lg") {
        HStack(alignment: .center, spacing: 16) {
          ForEach([IconSize.xsm, .sm, .md, .lg], id: \.self) { size in
            Icon(.search, color: .primary, size: size)
          }
        }
      }
      CaptureRow(title: "Colors: primary secondary tertiary disabled accent success error warning") {
        HStack(spacing: 12) {
          ForEach(IconColor.allCases.filter { $0 != .inherit }, id: \.self) { color in
            Icon(.info, color: color, size: .lg)
          }
        }
      }
      CaptureRow(title: "inherit: takes the surrounding foreground") {
        HStack(spacing: 12) {
          Icon(.check, size: .lg).foregroundStyle(.pink)
          Icon(.check, size: .lg).foregroundStyle(.blue)
        }
      }
      CaptureRow(title: "Every built-in name (md, primary)") {
        LazyVGrid(columns: Array(repeating: GridItem(.fixed(28), spacing: 8), count: 10), alignment: .leading, spacing: 10) {
          ForEach(IconName.builtIn, id: \.self) { name in
            Icon(name, color: .primary)
          }
        }
      }
      CaptureRow(title: "Status icons beside text, labeled") {
        VStack(alignment: .leading, spacing: 6) {
          HStack { Icon(.success, color: .success, label: "Completed"); SwiftUI.Text("Deploy finished") }
          HStack { Icon(.warning, color: .warning, label: "Warning"); SwiftUI.Text("Quota at 90%") }
          HStack { Icon(.error, color: .error, label: "Failed"); SwiftUI.Text("Sync failed") }
        }
      }
      CaptureRow(title: "Themes: default, neutral, butter (accent)") {
        HStack(spacing: 16) {
          Icon(.stop, color: .accent, size: .lg)
          Icon(.stop, color: .accent, size: .lg).astryxTheme(.neutral)
          Icon(.stop, color: .accent, size: .lg).astryxTheme(.butter)
        }
      }
    }
  }
}
