import Astryx
import AstryxNative
import SwiftUI

/// Evidence for component:swift/Button FR7–FR11: one variant per launch, the
/// real Astryx Button in the navigation bar, the bottom bar, a floating
/// container, and content. Launch with `-fullScreen YES -state
/// unset|primary|secondary|ghost|destructive` (a `-ic` suffix runs with
/// Increase Contrast on).
struct ButtonGlassScreen: View {
  private let state = UserDefaults.standard.string(forKey: "state") ?? "unset"
  @Environment(\.accessibilityReduceTransparency) private var reducesTransparency
  @Environment(\.colorSchemeContrast) private var contrast
  private var variant: ButtonVariant? {
    ButtonVariant(rawValue: state.replacingOccurrences(of: "-ic", with: "").replacingOccurrences(of: "-rt", with: ""))
  }
  private var name: String { variant?.rawValue ?? "not set" }
  private static let colors: [Color] = [.blue, .orange, .green, .pink, .purple, .teal, .indigo, .red]

  var body: some View {
    NavigationStack {
      ScrollViewReader { proxy in
        ScrollView {
          VStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
              SwiftUI.Text("variant: \(name)\(state.hasSuffix("-ic") ? " · Increase Contrast" : "")")
                .font(.headline)
              SwiftUI.Text("In content (token look):").font(.caption)
              HStack {
                Astryx.Button(label: "Share", variant: variant) {}
                Astryx.Button(label: "Elevated", variant: variant, elevation: .med) {}
              }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(Color(uiColor: .systemBackground), in: RoundedRectangle(cornerRadius: 12))
            .dynamicTypeSize(.large)
            ForEach(0..<24, id: \.self) { index in
              RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Self.colors[index % Self.colors.count].gradient)
                .frame(height: 72)
                .id(index)
            }
          }
          .padding(.horizontal, 16)
        }
        .overlay {
          // What the app itself reads, so a capture proves the setting.
          SwiftUI.Text("Reduce Transparency \(reducesTransparency ? "on" : "off") · Increase Contrast \(contrast == .increased ? "on" : "off")")
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10).padding(.vertical, 6)
            .background(Color(uiColor: .systemBackground), in: Capsule())
        }
        .overlay(alignment: .bottom) {
          HStack(spacing: 12) {
            Astryx.Button(label: "New", variant: variant) {}
            Astryx.Button(label: "Fill", variant: variant, width: .fill) {}
          }
          .astryxFloating()
          .padding(.horizontal, 16)
          .padding(.bottom, 96)
        }
        .task {
          try? await Task.sleep(for: .milliseconds(400))
          proxy.scrollTo(2, anchor: .top)
        }
      }
      .navigationTitle("Library")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Astryx.Button(label: "Share", variant: variant) {}
        }
        ToolbarItem(placement: .bottomBar) {
          Astryx.Button(label: "Archive", variant: variant) {}
        }
      }
    }
    .astryxTheme()
  }
}
