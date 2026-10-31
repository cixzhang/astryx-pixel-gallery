import Astryx
import AstryxNative
import SwiftUI
import UIKit

/// Prototype for the Swift Button glass spec (not Astryx code): a probe tells
/// a Button whether it sits in a system bar, and the Button then drops its own
/// fill so the bar's glass shows. Launch with `-fullScreen YES -state rest|scrolled|animate`.
struct GlassBarProbeScreen: View {
  var body: some View {
    if #available(iOS 26, *) {
      GlassBarProbeDemo()
    } else {
      SwiftUI.Text("Needs iOS 26")
    }
  }
}

/// Reports whether this view is hosted inside a UINavigationBar or UIToolbar.
private struct BarProbe: UIViewRepresentable {
  let report: (Bool) -> Void

  func makeUIView(context: Context) -> ProbeView {
    let view = ProbeView()
    view.report = report
    view.isUserInteractionEnabled = false
    return view
  }

  func updateUIView(_ view: ProbeView, context: Context) {}

  final class ProbeView: UIView {
    var report: ((Bool) -> Void)?
    override func didMoveToWindow() {
      super.didMoveToWindow()
      var node = superview
      var inBar = false
      while let view = node {
        if view is UINavigationBar || view is UIToolbar { inBar = true; break }
        node = view.superview
      }
      let found = inBar
      Task { @MainActor in self.report?(found) }
    }
  }
}

/// An Astryx Button that, in a system bar, draws the ghost look (no fill of its own).
private struct BarAwareButton: View {
  let label: String
  let variant: ButtonVariant
  @State private var inBar = false

  var body: some View {
    Astryx.Button(label: label, variant: inBar ? .ghost : variant) {}
      .background(BarProbe { inBar = $0 }.frame(width: 0, height: 0))
  }
}

@available(iOS 26, *)
private struct GlassBarProbeDemo: View {
  private let state = UserDefaults.standard.string(forKey: "state") ?? "rest"
  private static let colors: [Color] = [.blue, .orange, .green, .pink, .purple, .teal, .indigo, .red]

  var body: some View {
    NavigationStack {
      ScrollViewReader { proxy in
        ScrollView {
          VStack(spacing: 12) {
            Color.clear.frame(height: 1).id(-1)
            VStack(alignment: .leading, spacing: 6) {
              SwiftUI.Text("Top bar, left to right: native gear · Astryx today · Astryx with the bar probe")
              SwiftUI.Text("Below, the same probe button in content (must keep its fill):")
              BarAwareButton(label: "In content", variant: .secondary)
            }
            .font(.caption.weight(.semibold))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(Color(uiColor: .systemBackground), in: RoundedRectangle(cornerRadius: 12))
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
        }
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
          Astryx.Button(label: "Today", variant: .secondary) {}
        }
        ToolbarItem(placement: .topBarTrailing) {
          BarAwareButton(label: "Probe", variant: .secondary)
        }
        ToolbarItem(placement: .bottomBar) {
          BarAwareButton(label: "Probe in bottom bar", variant: .secondary)
        }
      }
    }
    .astryxTheme()
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
