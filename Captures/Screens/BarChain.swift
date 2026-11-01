import SwiftUI
import UIKit

/// Diagnostic for bar detection: prints the UIKit ancestor classes of a probe
/// in the navigation bar and in the bottom toolbar, checked on every hook.
struct BarChainScreen: View {
  @State private var nav = "nav: (none yet)"
  @State private var bottom = "bottom: (none yet)"

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 12) {
          SwiftUI.Text(nav).font(.system(size: 9, design: .monospaced))
          SwiftUI.Text(bottom).font(.system(size: 9, design: .monospaced))
        }
        .padding(12)
      }
      .navigationTitle("Chain")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          SwiftUI.Button("Nav") {}
            .background(ChainProbe { nav = "nav: " + $0 }.frame(width: 1, height: 1))
        }
        ToolbarItem(placement: .bottomBar) {
          SwiftUI.Button("Bottom") {}
            .background(ChainProbe { bottom = "bottom: " + $0 }.frame(width: 1, height: 1))
        }
      }
    }
  }
}

private struct ChainProbe: UIViewRepresentable {
  let report: (String) -> Void
  func makeUIView(context: Context) -> ProbeView {
    let view = ProbeView()
    view.report = report
    return view
  }
  func updateUIView(_ view: ProbeView, context: Context) {}

  final class ProbeView: UIView {
    var report: ((String) -> Void)?
    private var last = ""
    override func didMoveToWindow() { super.didMoveToWindow(); check("win") }
    override func didMoveToSuperview() { super.didMoveToSuperview(); check("sup") }
    override func layoutSubviews() { super.layoutSubviews(); check("lay") }
    private func check(_ hook: String) {
      var names: [String] = []
      var node = superview
      while let view = node {
        names.append(String(describing: type(of: view)))
        node = view.superview
      }
      let found = names.contains { $0.contains("NavigationBar") || $0.contains("Toolbar") }
      let line = "[\(hook)] found=\(found) window=\(window != nil) chain=\(names.prefix(14).joined(separator: " < "))"
      guard line != last else { return }
      last = line
      let report = report
      Task { @MainActor in report?(line) }
    }
  }
}
