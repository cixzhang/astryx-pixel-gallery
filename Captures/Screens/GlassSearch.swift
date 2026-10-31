import Astryx
import AstryxNative
import SwiftUI

/// iOS 26 toolbar search, minimized to a glass button and expanding into the
/// field, beside an Astryx TextInput and Button in a bar of their own.
/// Launch with `-fullScreen YES -state rest|presented|animate`.
struct GlassSearchScreen: View {
  var body: some View {
    if #available(iOS 26, *) {
      GlassSearchDemo()
    } else {
      SwiftUI.Text("Needs iOS 26")
    }
  }
}

@available(iOS 26, *)
private struct GlassSearchDemo: View {
  @State private var query = ""
  @State private var presented = false
  @State private var astryxQuery = ""
  private let state = UserDefaults.standard.string(forKey: "state") ?? "rest"

  var body: some View {
    NavigationStack {
      List(0..<24, id: \.self) { index in
        SwiftUI.Text("Artifact \(index + 1)")
      }
      .navigationTitle("Library")
      .navigationBarTitleDisplayMode(.inline)
      .searchable(text: $query, isPresented: $presented, placement: .toolbar, prompt: "Search artifacts")
      .searchToolbarBehavior(.minimize)
      .toolbar {
        // With another bottom-bar action, the minimized search shows as a glass button.
        ToolbarItem(placement: .bottomBar) {
          SwiftUI.Button {} label: { Image(systemName: "plus") }
            .accessibilityLabel("New")
        }
        ToolbarSpacer(.flexible, placement: .bottomBar)
        DefaultToolbarItem(kind: .search, placement: .bottomBar)
      }
      .safeAreaInset(edge: .top) {
        VStack(alignment: .leading, spacing: 6) {
          SwiftUI.Text("Astryx: TextInput + Button (no system search)")
            .font(.caption.weight(.semibold)).foregroundStyle(.secondary)
            .dynamicTypeSize(.large)
          HStack(spacing: 8) {
            Astryx.TextInput(
              label: "Search artifacts", value: astryxQuery, onChange: { astryxQuery = $0 },
              isLabelHidden: true, placeholder: "Search artifacts")
            Astryx.Button(label: "Search", variant: .secondary) {}
          }
        }
        .padding(.horizontal, 16).padding(.vertical, 8)
        .background(Color(uiColor: .systemBackground))
      }
      .task { await drive() }
    }
    .astryxTheme()
  }

  private func drive() async {
    switch state {
    case "presented":
      try? await Task.sleep(for: .milliseconds(600))
      presented = true
    case "animate":
      try? await Task.sleep(for: .seconds(1.5))
      presented = true
      try? await Task.sleep(for: .seconds(3.5))
      presented = false
    default:
      break
    }
  }
}
