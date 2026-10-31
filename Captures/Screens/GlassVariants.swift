import Astryx
import AstryxNative
import SwiftUI

/// Prototype of the proposed Swift Button glass mapping (not Astryx code), one
/// variant per launch: `-fullScreen YES -state unset|primary|secondary|ghost|destructive`.
/// Each screen shows today's Astryx Button and the proposed treatment in the
/// navigation bar, the bottom bar, and floating over content.
struct GlassVariantsScreen: View {
  var body: some View {
    if #available(iOS 26, *) {
      GlassVariantsDemo()
    } else {
      SwiftUI.Text("Needs iOS 26")
    }
  }
}

private enum Place { case bar, floating }

@available(iOS 26, *)
private struct ProposedGlassButton: View {
  let label: String
  let variant: ButtonVariant?
  let place: Place
  @Environment(\.astryx) private var astryx

  var body: some View {
    let color = astryx.tokens.color
    if variant == .primary {
      SwiftUI.Button {} label: { SwiftUI.Text(label).foregroundStyle(color.onAccent) }
        .buttonStyle(.glassProminent).tint(color.accent)
    } else if variant == .destructive {
      SwiftUI.Button {} label: { SwiftUI.Text(label).foregroundStyle(color.onError) }
        .buttonStyle(.glassProminent).tint(color.error)
    } else if place == .bar && variant == nil {
      // Unset in a bar: the bar's own item, exactly as a native one.
      SwiftUI.Button(label) {}
    } else if place == .bar {
      // Secondary or ghost in a bar: the bar's glass, the variant's label color.
      SwiftUI.Button {} label: { SwiftUI.Text(label).foregroundStyle(color.textPrimary) }
    } else if variant == .ghost {
      SwiftUI.Button {} label: { SwiftUI.Text(label).foregroundStyle(color.textPrimary) }
        .buttonStyle(.glass(.clear))
    } else {
      // Secondary, or unset under the floating opt-in (secondary is the default).
      SwiftUI.Button {} label: { SwiftUI.Text(label).foregroundStyle(color.textPrimary) }
        .buttonStyle(.glass)
    }
  }
}

@available(iOS 26, *)
private struct GlassVariantsDemo: View {
  private let state = UserDefaults.standard.string(forKey: "state") ?? "unset"
  private var variant: ButtonVariant? { ButtonVariant(rawValue: state) }
  private static let colors: [Color] = [.blue, .orange, .green, .pink, .purple, .teal, .indigo, .red]

  private func today(_ label: String) -> some View {
    Astryx.Button(label: label, variant: variant) {}
  }

  var body: some View {
    NavigationStack {
      ScrollViewReader { proxy in
        ScrollView {
          VStack(spacing: 12) {
            ForEach(0..<24, id: \.self) { index in
              RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Self.colors[index % Self.colors.count].gradient)
                .frame(height: 72)
                .id(index)
            }
          }
          .padding(.horizontal, 16)
        }
        .task {
          try? await Task.sleep(for: .milliseconds(300))
          proxy.scrollTo(2, anchor: .top)
        }
      }
      .overlay {
        VStack(spacing: 14) {
          SwiftUI.Text("variant: \(variant?.rawValue ?? "not set")")
            .font(.headline)
          HStack(spacing: 16) {
            VStack(spacing: 6) { today("Share"); tag("today") }
            VStack(spacing: 6) { ProposedGlassButton(label: "Share", variant: variant, place: .floating); tag("proposed, floating") }
          }
          SwiftUI.Text("Bars: left of each pair is today, right is proposed")
            .font(.caption)
        }
        .padding(16)
        .background(Color(uiColor: .systemBackground).opacity(0.0))
      }
      .navigationTitle("Library")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarLeading) { today("Today") }
        ToolbarItem(placement: .topBarTrailing) { ProposedGlassButton(label: "Share", variant: variant, place: .bar) }
        ToolbarItem(placement: .bottomBar) { today("Today") }
        ToolbarSpacer(.flexible, placement: .bottomBar)
        ToolbarItem(placement: .bottomBar) { ProposedGlassButton(label: "Share", variant: variant, place: .bar) }
      }
    }
    .astryxTheme()
  }

  private func tag(_ text: String) -> some View {
    SwiftUI.Text(text)
      .font(.caption2.weight(.semibold))
      .padding(.horizontal, 6).padding(.vertical, 2)
      .background(Color(uiColor: .systemBackground), in: Capsule())
      .dynamicTypeSize(.large)
  }
}
