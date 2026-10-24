// Shows one capture screen, chosen by launch argument: `-screen Icon`.
import Astryx
import SwiftUI

@main
struct CapturesApp: App {
  var body: some Scene {
    WindowGroup {
      let name = UserDefaults.standard.string(forKey: "screen") ?? ""
      ScrollView {
        captureScreen(named: name)
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(16)
      }
      .background(Color(uiColor: .systemBackground))
    }
  }
}

/// A titled row of states inside a capture screen.
struct CaptureRow<Content: View>: View {
  let title: String
  @ViewBuilder let content: Content
  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      SwiftUI.Text(title).font(.caption).foregroundStyle(.secondary)
      content
    }
    .padding(.vertical, 6)
  }
}
