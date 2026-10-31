import Astryx
import AstryxNative
import SwiftUI

/// iOS 26 bars over scrolling content: a native toolbar button, a native glass
/// button, the Artifacts app's scroll-driven circle, and Astryx Buttons in the
/// same places. Launch with `-fullScreen YES -state rest|scrolled|animate`.
struct GlassButtonsScreen: View {
  var body: some View {
    if #available(iOS 26, *) {
      GlassButtonsDemo()
    } else {
      SwiftUI.Text("Needs iOS 26")
    }
  }
}

@available(iOS 26, *)
private struct GlassButtonsDemo: View {
  @State private var offset: CGFloat = 0
  private let state = UserDefaults.standard.string(forKey: "state") ?? "rest"
  private static let colors: [Color] = [.blue, .orange, .green, .pink, .purple, .teal, .indigo, .red]

  /// The Artifacts app's progress: 0 at rest, 1 once the list has scrolled 80 points.
  private var progress: Double { min(1, max(0, Double(offset) / 80)) }

  var body: some View {
    NavigationStack {
      ScrollViewReader { proxy in
        ScrollView {
          VStack(spacing: 12) {
            Color.clear.frame(height: 1).id(-1)
            ForEach(0..<24, id: \.self) { index in
              RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Self.colors[index % Self.colors.count].gradient)
                .frame(height: 72)
                .overlay(alignment: .leading) {
                  SwiftUI.Text("Artifact \(index + 1)").font(.headline).foregroundStyle(.white).padding(.leading, 16)
                }
                .id(index)
            }
          }
          .padding(.horizontal, 16)
          .padding(.top, 84)
        }
        .onScrollGeometryChange(for: CGFloat.self) { $0.contentOffset.y + $0.contentInsets.top } action: { _, now in
          offset = now
        }
        .overlay(alignment: .top) { floatingRow.padding(.top, 8) }
        .task { await drive(proxy) }
      }
      .navigationTitle("Library")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          SwiftUI.Button {} label: { Image(systemName: "gearshape") }
            .accessibilityLabel("Native toolbar button")
        }
        ToolbarItem(placement: .topBarTrailing) {
          Astryx.Button(label: "Share", variant: .secondary) {}
        }
      }
    }
    .astryxTheme()
  }

  private var floatingRow: some View {
    HStack(alignment: .top, spacing: 14) {
      captioned("native .glass") {
        SwiftUI.Button("Share") {}.buttonStyle(.glass)
      }
      captioned("Artifacts app") {
        Image(systemName: "magnifyingglass")
          .font(.system(size: 18, weight: .medium))
          .frame(width: 44, height: 44)
          .background {
            ZStack {
              Circle().fill(Color(uiColor: .tertiarySystemFill)).opacity(1 - progress)
              Color.clear.glassEffect(.regular.interactive(), in: Circle()).opacity(progress)
            }
          }
      }
      captioned("Astryx secondary") {
        Astryx.Button(label: "Share", variant: .secondary) {}
      }
      captioned("Astryx ghost") {
        Astryx.Button(label: "Share", variant: .ghost) {}
      }
    }
  }

  private func captioned<Content: View>(_ caption: String, @ViewBuilder _ content: () -> Content) -> some View {
    VStack(spacing: 4) {
      content()
      SwiftUI.Text(caption)
        .font(.caption2.weight(.semibold))
        .padding(.horizontal, 6).padding(.vertical, 2)
        .background(Color(uiColor: .systemBackground), in: Capsule())
        .dynamicTypeSize(.large)
    }
  }

  private func drive(_ proxy: ScrollViewProxy) async {
    switch state {
    case "scrolled":
      try? await Task.sleep(for: .milliseconds(400))
      proxy.scrollTo(4, anchor: .top)
    case "animate":
      try? await Task.sleep(for: .seconds(1.5))
      withAnimation(.easeInOut(duration: 2.5)) { proxy.scrollTo(6, anchor: .top) }
      try? await Task.sleep(for: .seconds(3.5))
      withAnimation(.easeInOut(duration: 2.5)) { proxy.scrollTo(-1, anchor: .top) }
    default:
      break
    }
  }
}
