import Astryx
import AstryxNative
import SwiftUI

/// Research for a native-tuned default theme (no Astryx change). One inbox
/// screen in four states, real Astryx components throughout:
/// - `current`: the default theme as it ships.
/// - `glass`: prototype of native intent (AST-082 FR10 `material`): card
///   surfaces drawn as system glass; tokens unchanged.
/// - `tuned`: prototype of a native theme that extends the default with
///   token deltas: 44-point controls, iOS-sized type, larger corners, softer
///   elevation.
/// - `both`: `tuned` tokens with `glass` surfaces.
/// Launch with `-fullScreen YES -state current|glass|tuned|both`.
struct NativeThemeScreen: View {
  var body: some View {
    if #available(iOS 26, *) {
      NativeThemeContent()
    } else {
      SwiftUI.Text("iOS 26 only")
    }
  }
}

@available(iOS 26, *)
private struct NativeThemeContent: View {
  private let state = UserDefaults.standard.string(forKey: "state") ?? "current"
  private var isGlass: Bool { state == "glass" || state == "both" }
  private var isTuned: Bool { state == "tuned" || state == "both" }
  @State private var query = ""

  /// The default theme with native-sized tokens (prototype values).
  static let tuned: Theme = {
    var theme = Theme.default
    for mode in [\Theme.light, \Theme.dark] as [WritableKeyPath<Theme, Tokens>] {
      var t = theme[keyPath: mode]
      t.radius.element = 22
      t.radius.container = 26
      t.radius.inner = 10
      t.size.elementSm = 36
      t.size.elementMd = 44
      t.size.elementLg = 50
      t.font.body.size = 17
      t.font.label.size = 17
      t.font.supporting.size = 15
      t.font.heading2.size = 22
      t.font.heading3.size = 20
      let soft = t.shadow.low.map { ShadowLayer(x: 0, y: $0.y * 2, blur: $0.blur * 2.5, color: $0.color) }
      t.shadow.low = soft
      theme[keyPath: mode] = t
    }
    return theme
  }()

  var body: some View {
    TabView {
      Tab("Inbox", systemImage: "tray") { inbox }
      Tab("Search", systemImage: "magnifyingglass") { Color.clear }
      Tab("Settings", systemImage: "gearshape") { Color.clear }
    }
    .astryxTheme(isTuned ? Self.tuned : .default)
  }

  private var inbox: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 16) {
          SwiftUI.Text("theme: \(state)").font(.caption.monospaced()).foregroundStyle(.secondary)
          Astryx.TextInput(label: "Search mail", value: query, onChange: { query = $0 }, isLabelHidden: true, placeholder: "Search mail")
          Astryx.Heading("Today", level: .v2)
          surface {
            VStack(spacing: 0) {
              row("Ada Lovelace", "Notes on the analytical engine")
              row("Grace Hopper", "Compiler review moved to Friday")
              row("Alan Turing", "Re: the imitation game")
            }
          }
          HStack(spacing: 12) {
            Astryx.Button(label: "New message", variant: .primary) {}
            Astryx.Button(label: "Archive all", variant: .secondary) {}
          }
          Astryx.Heading("Earlier", level: .v2)
          surface {
            VStack(spacing: 0) {
              row("Katherine Johnson", "Trajectory numbers attached")
              row("Margaret Hamilton", "Flight software sign-off")
              row("Edsger Dijkstra", "On the cruelty of really teaching")
            }
          }
          ForEach(0..<4, id: \.self) { _ in
            RoundedRectangle(cornerRadius: 16).fill(.indigo.gradient.opacity(0.35)).frame(height: 90)
          }
        }
        .padding(16)
      }
      .background(Color(uiColor: .systemGroupedBackground))
      .navigationTitle("Inbox")
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          SwiftUI.Button {} label: { Image(systemName: "square.and.pencil") }
        }
      }
    }
  }

  private func row(_ name: String, _ subject: String) -> some View {
    Astryx.Item(name, description: subject) {
      Astryx.Avatar(name, size: .md)
    }
  }

  /// The card a group of rows sits on: Astryx's Card, or (glass states) a
  /// prototype system-glass surface in the theme's container radius.
  @ViewBuilder private func surface<C: View>(@ViewBuilder _ content: () -> C) -> some View {
    if isGlass {
      GlassSurface(content: content())
    } else {
      Astryx.Card(elevation: .low) { content() }
    }
  }
}

@available(iOS 26, *)
private struct GlassSurface<Content: View>: View {
  let content: Content
  @Environment(\.astryx) private var astryx

  var body: some View {
    content
      .padding(astryx.tokens.space.s4)
      .glassEffect(.regular, in: RoundedRectangle(cornerRadius: astryx.tokens.radius.container, style: .continuous))
  }
}
